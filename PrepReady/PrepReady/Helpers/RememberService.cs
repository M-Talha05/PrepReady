using System;
using System.Data;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.SessionState;

namespace PrepReady.Helpers
{
    /// <summary>EX-16: secure "remember me" trusted-device tokens (selector/validator pattern).
    /// Cookie = "selector:validator". DB stores only SHA-256(validator), looked up by the indexed
    /// selector, compared in constant time. Members only; the validator rotates on every use.</summary>
    public static class RememberService
    {
        private const string CookieName = "PR_REMEMBER";
        private const int DaysValid = 30;

        // ---------- issue (after a fully completed login) ----------
        public static void IssueToken(int userId, HttpResponse response)
        {
            string selector = RandomHex(16);    // 32 hex chars
            string validator = RandomHex(32);   // 64 hex chars
            DateTime expiry = DateTime.Now.AddDays(DaysValid);

            DBHelper.ExecuteNonQuery(
                "INSERT INTO RememberTokens (UserId, Selector, ValidatorHash, Expiry) VALUES (@U, @S, @H, @E)",
                DBHelper.Param("@U", userId),
                DBHelper.Param("@S", selector),
                DBHelper.Param("@H", Sha256Hex(validator)),
                DBHelper.Param("@E", expiry));

            WriteCookie(response, selector + ":" + validator, expiry);
        }

        // ---------- validate + auto-login (from Global.asax Session_Start) ----------
        public static void TryAutoLogin(HttpContext ctx)
        {
            HttpCookie cookie = ctx.Request.Cookies[CookieName];
            if (cookie == null || string.IsNullOrEmpty(cookie.Value)) return;

            string[] parts = cookie.Value.Split(':');
            if (parts.Length != 2) { ExpireCookie(ctx.Response); return; }

            string selector = parts[0];
            string validator = parts[1];

            DataRow row = DBHelper.ExecuteSingleRow(
                "SELECT t.UserId, t.ValidatorHash, t.Expiry, " +
                "       u.FullName, u.Role, u.Email, u.IsActive, u.IsEmailVerified " +
                "FROM RememberTokens t INNER JOIN Users u ON u.UserId = t.UserId " +
                "WHERE t.Selector = @S",
                DBHelper.Param("@S", selector));

            if (row == null) { ExpireCookie(ctx.Response); return; }

            if (Convert.ToDateTime(row["Expiry"]) <= DateTime.Now)
            {
                DeleteBySelector(selector); ExpireCookie(ctx.Response); return;
            }

            // Constant-time compare; a wrong validator for a real selector implies theft -> nuke it.
            if (!FixedTimeEquals(Convert.ToString(row["ValidatorHash"]), Sha256Hex(validator)))
            {
                DeleteBySelector(selector); ExpireCookie(ctx.Response); return;
            }

            // Members only; account must be active + verified.
            string role = Convert.ToString(row["Role"]);
            bool eligible = role == "Member"
                            && Convert.ToBoolean(row["IsActive"])
                            && Convert.ToBoolean(row["IsEmailVerified"]);
            if (!eligible)
            {
                DeleteBySelector(selector); ExpireCookie(ctx.Response); return;
            }

            int userId = Convert.ToInt32(row["UserId"]);
            DateTime expiry = Convert.ToDateTime(row["Expiry"]);

            // Rotate the validator (single-use), keep selector + original expiry.
            string newValidator = RandomHex(32);
            DBHelper.ExecuteNonQuery(
                "UPDATE RememberTokens SET ValidatorHash=@H WHERE Selector=@S",
                DBHelper.Param("@H", Sha256Hex(newValidator)),
                DBHelper.Param("@S", selector));
            WriteCookie(ctx.Response, selector + ":" + newValidator, expiry);

            // Grant the session.
            HttpSessionState session = ctx.Session;
            session["UserId"] = userId;
            session["FullName"] = Convert.ToString(row["FullName"]);
            session["Role"] = role;
            session["Email"] = Convert.ToString(row["Email"]);
            session["AvatarPath"] = null;

            AuditService.Log(Convert.ToString(row["Email"]), userId, true,
                ctx.Request.UserHostAddress, "Auto-login (remember me)");
        }

        // ---------- clear (logout) ----------
        public static void ClearToken(HttpRequest request, HttpResponse response)
        {
            HttpCookie cookie = request.Cookies[CookieName];
            if (cookie != null && !string.IsNullOrEmpty(cookie.Value))
            {
                string[] parts = cookie.Value.Split(':');
                if (parts.Length == 2) DeleteBySelector(parts[0]);
            }
            ExpireCookie(response);
        }

        /// <summary>Invalidate every trusted device for a user (call on password change/reset/delete).</summary>
        public static void RemoveAllForUser(int userId)
        {
            DBHelper.ExecuteNonQuery("DELETE FROM RememberTokens WHERE UserId=@U", DBHelper.Param("@U", userId));
        }

        // ---------- helpers ----------
        private static void DeleteBySelector(string selector)
        {
            DBHelper.ExecuteNonQuery("DELETE FROM RememberTokens WHERE Selector=@S", DBHelper.Param("@S", selector));
        }

        private static void WriteCookie(HttpResponse response, string value, DateTime expiry)
        {
            HttpCookie cookie = new HttpCookie(CookieName, value);
            cookie.HttpOnly = true;
            cookie.Secure = HttpContext.Current != null && HttpContext.Current.Request.IsSecureConnection;
            cookie.Path = "/";
            cookie.Expires = expiry;
            cookie.SameSite = SameSiteMode.Lax;
            response.Cookies.Add(cookie);
        }

        private static void ExpireCookie(HttpResponse response)
        {
            HttpCookie cookie = new HttpCookie(CookieName, "");
            cookie.HttpOnly = true;
            cookie.Path = "/";
            cookie.Expires = DateTime.Now.AddDays(-1);
            response.Cookies.Add(cookie);
        }

        private static string RandomHex(int byteCount)
        {
            byte[] buf = new byte[byteCount];
            using (RNGCryptoServiceProvider rng = new RNGCryptoServiceProvider())
                rng.GetBytes(buf);
            StringBuilder sb = new StringBuilder(byteCount * 2);
            foreach (byte b in buf) sb.Append(b.ToString("x2"));
            return sb.ToString();
        }

        private static string Sha256Hex(string input)
        {
            using (SHA256 sha = SHA256.Create())
            {
                byte[] hash = sha.ComputeHash(Encoding.UTF8.GetBytes(input));
                StringBuilder sb = new StringBuilder(hash.Length * 2);
                foreach (byte b in hash) sb.Append(b.ToString("x2"));
                return sb.ToString();
            }
        }

        // Length-constant comparison to avoid timing attacks.
        private static bool FixedTimeEquals(string a, string b)
        {
            if (a == null || b == null || a.Length != b.Length) return false;
            int diff = 0;
            for (int i = 0; i < a.Length; i++) diff |= a[i] ^ b[i];
            return diff == 0;
        }
    }
}