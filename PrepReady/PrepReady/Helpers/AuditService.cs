using System;
using System.Data;

namespace PrepReady.Helpers
{
    public static class AuditService
    {
        public const int MaxAttempts = 5;      // failures before lockout
        public const int LockoutMinutes = 15;  // how long the lock lasts

        /// <summary>Records one login attempt.</summary>
        public static void Log(string email, int? userId, bool success, string ip, string note)
        {
            DBHelper.ExecuteNonQuery(
                "INSERT INTO LoginAudit (Email, UserId, Success, IpAddress, Note) " +
                "VALUES (@Email, @UserId, @Success, @Ip, @Note)",
                DBHelper.Param("@Email", email),
                DBHelper.Param("@UserId", userId.HasValue ? (object)userId.Value : null),
                DBHelper.Param("@Success", success),
                DBHelper.Param("@Ip", ip),
                DBHelper.Param("@Note", note));
        }

        /// <summary>Returns the lockout-until time if the account is currently locked, else null.</summary>
        public static DateTime? GetActiveLockout(string email)
        {
            DataRow r = DBHelper.ExecuteSingleRow(
                "SELECT LockoutUntil FROM Users WHERE Email = @Email",
                DBHelper.Param("@Email", email));

            if (r == null || r["LockoutUntil"] == DBNull.Value) return null;

            DateTime until = Convert.ToDateTime(r["LockoutUntil"]);
            return until > DateTime.Now ? until : (DateTime?)null;
        }

        /// <summary>
        /// Records a failed password attempt: increments the counter and locks the
        /// account if the threshold is hit. Returns the lockout-until time if this
        /// attempt triggered a lock, otherwise null.
        /// </summary>
        public static DateTime? RegisterFailure(int userId)
        {
            DBHelper.ExecuteNonQuery(
                "UPDATE Users SET FailedLoginCount = FailedLoginCount + 1 WHERE UserId = @UserId",
                DBHelper.Param("@UserId", userId));

            int count = Convert.ToInt32(DBHelper.ExecuteScalar(
                "SELECT FailedLoginCount FROM Users WHERE UserId = @UserId",
                DBHelper.Param("@UserId", userId)));

            if (count >= MaxAttempts)
            {
                DateTime until = DateTime.Now.AddMinutes(LockoutMinutes);
                DBHelper.ExecuteNonQuery(
                    "UPDATE Users SET LockoutUntil = @Until, FailedLoginCount = 0 WHERE UserId = @UserId",
                    DBHelper.Param("@Until", until),
                    DBHelper.Param("@UserId", userId));
                return until;
            }
            return null;
        }

        /// <summary>Clears failure counter + lockout on a successful login.</summary>
        public static void ResetFailures(int userId)
        {
            DBHelper.ExecuteNonQuery(
                "UPDATE Users SET FailedLoginCount = 0, LockoutUntil = NULL WHERE UserId = @UserId",
                DBHelper.Param("@UserId", userId));
        }

        /// <summary>Most recent attempts for the admin viewer.</summary>
        public static DataTable GetRecent(int top)
        {
            return DBHelper.ExecuteDataTable(
                "SELECT TOP (@Top) a.AuditId, a.Email, a.Success, a.IpAddress, a.Note, a.AttemptDate, u.FullName " +
                "FROM LoginAudit a LEFT JOIN Users u ON u.UserId = a.UserId " +
                "ORDER BY a.AttemptDate DESC",
                DBHelper.Param("@Top", top));
        }
    }
}