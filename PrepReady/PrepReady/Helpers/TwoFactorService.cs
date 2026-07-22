using System;
using System.Data;

namespace PrepReady.Helpers
{
    public static class TwoFactorService
    {
        private const int OtpMinutes = 5;

        public static bool IsEnabled(int userId)
        {
            object o = DBHelper.ExecuteScalar(
                "SELECT TwoFactorEnabled FROM Users WHERE UserId=@U", DBHelper.Param("@U", userId));
            return o != null && o != DBNull.Value && Convert.ToBoolean(o);
        }

        public static void SetEnabled(int userId, bool enabled)
        {
            // Turning it off also clears any pending code.
            DBHelper.ExecuteNonQuery(
                "UPDATE Users SET TwoFactorEnabled=@E, OtpCode=NULL, OtpExpiry=NULL WHERE UserId=@U",
                DBHelper.Param("@E", enabled), DBHelper.Param("@U", userId));
        }

        // Generate + store a 6-digit code; returns it so the caller can email/log it.
        public static string GenerateOtp(int userId)
        {
            string code = new Random().Next(0, 1000000).ToString("D6");
            DBHelper.ExecuteNonQuery(
                "UPDATE Users SET OtpCode=@C, OtpExpiry=@X WHERE UserId=@U",
                DBHelper.Param("@C", code),
                DBHelper.Param("@X", DateTime.Now.AddMinutes(OtpMinutes)),
                DBHelper.Param("@U", userId));
            return code;
        }

        // True only if the code matches AND hasn't expired. Clears the code on success.
        public static bool VerifyOtp(int userId, string code)
        {
            DataRow r = DBHelper.ExecuteSingleRow(
                "SELECT OtpCode, OtpExpiry FROM Users WHERE UserId=@U", DBHelper.Param("@U", userId));
            if (r == null) return false;
            if (r["OtpCode"] == DBNull.Value || r["OtpExpiry"] == DBNull.Value) return false;

            string stored = Convert.ToString(r["OtpCode"]);
            DateTime exp = Convert.ToDateTime(r["OtpExpiry"]);
            if (DateTime.Now > exp) return false;
            if (!string.Equals(stored, (code ?? "").Trim(), StringComparison.Ordinal)) return false;

            ClearOtp(userId);
            return true;
        }

        public static void ClearOtp(int userId)
        {
            DBHelper.ExecuteNonQuery(
                "UPDATE Users SET OtpCode=NULL, OtpExpiry=NULL WHERE UserId=@U", DBHelper.Param("@U", userId));
        }
    }
}