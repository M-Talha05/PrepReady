using System;
using System.Data;

namespace PrepReady.Helpers
{
    /// <summary>
    /// Authentication helpers: BCrypt hashing/verification, member registration,
    /// email-token verification, and seeding the admin/officer passwords.
    /// </summary>
    public static class AuthService
    {
        // ---------- Hashing ----------
        public static string HashPassword(string plain)
        {
            return BCrypt.Net.BCrypt.HashPassword(plain);
        }

        public static bool VerifyPassword(string plain, string storedHash)
        {
            try
            {
                return BCrypt.Net.BCrypt.Verify(plain, storedHash);
            }
            catch
            {
                // storedHash is not a valid BCrypt hash (e.g. the placeholder).
                return false;
            }
        }

        /// <summary>EX-15: verify a plaintext password against the stored hash for a user id
        /// (used for the account self-delete confirmation).</summary>
        public static bool VerifyUserPassword(int userId, string password)
        {
            System.Data.DataRow row = DBHelper.ExecuteSingleRow(
                "SELECT PasswordHash FROM Users WHERE UserId = @U",
                DBHelper.Param("@U", userId));
            if (row == null) return false;

            string storedHash = row["PasswordHash"] == System.DBNull.Value
                ? "" : row["PasswordHash"].ToString();
            return VerifyPassword(password, storedHash);
        }

        public static string GenerateToken()
        {
            return Guid.NewGuid().ToString("N");
        }

        // ---------- Lookups ----------
        public static DataRow GetUserByEmail(string email)
        {
            return DBHelper.ExecuteSingleRow(
                "SELECT * FROM Users WHERE Email = @Email",
                DBHelper.Param("@Email", email));
        }

        public static DataRow GetOfficerByEmail(string email)
        {
            return DBHelper.ExecuteSingleRow(
                "SELECT * FROM Officers WHERE Email = @Email",
                DBHelper.Param("@Email", email));
        }

        /// <summary>True if the email is already used by a member OR an officer.</summary>
        public static bool EmailExists(string email)
        {
            int users = Convert.ToInt32(DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Users WHERE Email = @Email",
                DBHelper.Param("@Email", email)));
            int officers = Convert.ToInt32(DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Officers WHERE Email = @Email",
                DBHelper.Param("@Email", email)));
            return users > 0 || officers > 0;
        }

        // ---------- Registration ----------
        public static int RegisterMember(string fullName, string email, string plainPassword, string token)
        {
            string sql =
                "INSERT INTO Users (FullName, Email, PasswordHash, IsEmailVerified, EmailVerifyToken, Role) " +
                "VALUES (@FullName, @Email, @Hash, 0, @Token, 'Member'); " +
                "SELECT CAST(SCOPE_IDENTITY() AS INT);";

            object id = DBHelper.ExecuteScalar(sql,
                DBHelper.Param("@FullName", fullName),
                DBHelper.Param("@Email", email),
                DBHelper.Param("@Hash", HashPassword(plainPassword)),
                DBHelper.Param("@Token", token));

            return Convert.ToInt32(id);
        }

        /// <summary>Marks a member verified if the token matches an unverified account.</summary>
        public static bool VerifyEmailToken(string token)
        {
            int rows = DBHelper.ExecuteNonQuery(
                "UPDATE Users SET IsEmailVerified = 1, EmailVerifyToken = NULL " +
                "WHERE EmailVerifyToken = @Token AND IsEmailVerified = 0",
                DBHelper.Param("@Token", token));
            return rows > 0;
        }

        // ---------- Seed account finalization (called from Global.asax) ----------
        public static void EnsureSeedAccounts()
        {
            const string placeholder = "PENDING_PHASE3_SETUP";

            DataRow admin = GetUserByEmail("admin@prepready.local");
            if (admin != null && admin["PasswordHash"].ToString() == placeholder)
            {
                DBHelper.ExecuteNonQuery(
                    "UPDATE Users SET PasswordHash = @Hash, IsEmailVerified = 1 WHERE Email = @Email",
                    DBHelper.Param("@Hash", HashPassword("Admin@123")),
                    DBHelper.Param("@Email", "admin@prepready.local"));
            }

            DataRow officer = GetOfficerByEmail("officer@prepready.local");
            if (officer != null && officer["PasswordHash"].ToString() == placeholder)
            {
                DBHelper.ExecuteNonQuery(
                    "UPDATE Officers SET PasswordHash = @Hash WHERE Email = @Email",
                    DBHelper.Param("@Hash", HashPassword("Officer@123")),
                    DBHelper.Param("@Email", "officer@prepready.local"));
            }
        }

        // ===================================================================
        //  EX-1: Password reset & change password
        // ===================================================================

        /// <summary>
        /// Creates a 1-hour password-reset token for an ACTIVE Users-table account
        /// (Member/Admin). Returns the token, or null if no eligible account exists.
        /// Anti-enumeration: callers must show the SAME message whether or not this
        /// returns null.
        /// </summary>
        public static string CreatePasswordResetToken(string email)
        {
            if (string.IsNullOrWhiteSpace(email)) return null;

            System.Data.DataRow user = DBHelper.ExecuteSingleRow(
                "SELECT UserId, IsActive FROM Users WHERE Email = @Email",
                DBHelper.Param("@Email", email.Trim()));

            if (user == null) return null;
            if (user["IsActive"] != System.DBNull.Value && !System.Convert.ToBoolean(user["IsActive"]))
                return null;

            string token = GenerateToken();
            System.DateTime expiry = System.DateTime.Now.AddHours(1);

            DBHelper.ExecuteNonQuery(
                "UPDATE Users SET PasswordResetToken = @Token, PasswordResetExpiry = @Expiry " +
                "WHERE UserId = @UserId",
                DBHelper.Param("@Token", token),
                DBHelper.Param("@Expiry", expiry),
                DBHelper.Param("@UserId", System.Convert.ToInt32(user["UserId"])));

            return token;
        }

        /// <summary>
        /// Returns the UserId for a valid, non-expired reset token, or 0 if invalid/expired.
        /// </summary>
        public static int GetUserIdByResetToken(string token)
        {
            if (string.IsNullOrEmpty(token)) return 0;

            System.Data.DataRow row = DBHelper.ExecuteSingleRow(
                "SELECT UserId FROM Users " +
                "WHERE PasswordResetToken = @Token AND PasswordResetExpiry > @Now",
                DBHelper.Param("@Token", token),
                DBHelper.Param("@Now", System.DateTime.Now));

            return row == null ? 0 : System.Convert.ToInt32(row["UserId"]);
        }

        /// <summary>
        /// Consumes a valid reset token, sets a new BCrypt hash, clears the token and
        /// any lockout state. Returns false if the token is invalid/expired.
        /// </summary>
        public static bool ResetPassword(string token, string newPassword)
        {
            int userId = GetUserIdByResetToken(token);
            if (userId == 0) return false;

            string hash = HashPassword(newPassword);

            DBHelper.ExecuteNonQuery(
                "UPDATE Users SET PasswordHash = @Hash, " +
                "PasswordResetToken = NULL, PasswordResetExpiry = NULL, " +
                "FailedLoginCount = 0, LockoutUntil = NULL " +
                "WHERE UserId = @UserId",
                DBHelper.Param("@Hash", hash),
                DBHelper.Param("@UserId", userId));

            return true;
        }

        /// <summary>
        /// Changes the password for a logged-in user after verifying the current one.
        /// Returns false if the current password is wrong.
        /// </summary>
        public static bool ChangePassword(int userId, string currentPassword, string newPassword)
        {
            System.Data.DataRow row = DBHelper.ExecuteSingleRow(
                "SELECT PasswordHash FROM Users WHERE UserId = @UserId",
                DBHelper.Param("@UserId", userId));

            if (row == null) return false;

            string storedHash = row["PasswordHash"] == System.DBNull.Value
                ? "" : row["PasswordHash"].ToString();

            if (!VerifyPassword(currentPassword, storedHash)) return false;

            DBHelper.ExecuteNonQuery(
                "UPDATE Users SET PasswordHash = @Hash WHERE UserId = @UserId",
                DBHelper.Param("@Hash", HashPassword(newPassword)),
                DBHelper.Param("@UserId", userId));

            return true;
        }
    }
}