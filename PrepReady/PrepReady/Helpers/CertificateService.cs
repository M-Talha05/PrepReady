using System;
using System.Data;

namespace PrepReady.Helpers
{
    /// <summary>Certificate issuance, lookup, verification, and tier-eligibility logic.</summary>
    public static class CertificateService
    {
        public static DataRow GetCertificate(int userId, int courseId)
        {
            return DBHelper.ExecuteSingleRow(
                "SELECT * FROM Certificates WHERE UserId=@U AND CourseId=@C",
                DBHelper.Param("@U", userId), DBHelper.Param("@C", courseId));
        }

        /// <summary>Full cert details (joined with holder + course) for PDF/verification.</summary>
        public static DataRow GetByCode(string code)
        {
            return DBHelper.ExecuteSingleRow(
                "SELECT c.*, u.FullName, co.Title AS CourseTitle, co.CategoryName, co.GovPartner " +
                "FROM Certificates c " +
                "INNER JOIN Users u   ON u.UserId   = c.UserId " +
                "INNER JOIN Courses co ON co.CourseId = c.CourseId " +
                "WHERE c.CertCode = @Code",
                DBHelper.Param("@Code", code));
        }

        public static DataTable GetUserCertificates(int userId)
        {
            return DBHelper.ExecuteDataTable(
                "SELECT c.CertCode, c.Tier, c.IssueDate, c.ExpiryDate, " +
                "       co.CourseId, co.Title AS CourseTitle, co.CategoryName, co.GovPartner " +
                "FROM Certificates c INNER JOIN Courses co ON co.CourseId = c.CourseId " +
                "WHERE c.UserId = @U ORDER BY c.IssueDate DESC",
                DBHelper.Param("@U", userId));
        }

        /// <summary>EX-14: still-valid certs that expire within the next <paramref name="days"/> days,
        /// soonest first. Read-only — used by the Dashboard renewal reminder.</summary>
        public static DataTable GetExpiringSoon(int userId, int days)
        {
            DateTime now = DateTime.Now;
            return DBHelper.ExecuteDataTable(
                "SELECT c.CertCode, c.Tier, c.IssueDate, c.ExpiryDate, " +
                "       co.CourseId, co.Title AS CourseTitle, co.CategoryName " +
                "FROM Certificates c INNER JOIN Courses co ON co.CourseId = c.CourseId " +
                "WHERE c.UserId = @U AND c.ExpiryDate > @Now AND c.ExpiryDate <= @Cutoff " +
                "ORDER BY c.ExpiryDate ASC",
                DBHelper.Param("@U", userId),
                DBHelper.Param("@Now", now),
                DBHelper.Param("@Cutoff", now.AddDays(days)));
        }

        private static string GenerateCertCode(int courseId)
        {
            string rand = Guid.NewGuid().ToString("N").Substring(0, 8).ToUpper();
            return "PR" + courseId + "-" + rand;
        }

        /// <summary>Creates a Tier 1 cert if none exists; returns the cert code.</summary>
        public static string IssueTier1(int userId, int courseId, string verifyBaseUrl)
        {
            DataRow existing = GetCertificate(userId, courseId);
            if (existing != null) return existing["CertCode"].ToString();

            string code = GenerateCertCode(courseId);
            string qrData = verifyBaseUrl + code;
            DateTime issue = DateTime.Now;

            DBHelper.ExecuteNonQuery(
                "INSERT INTO Certificates (CertCode, UserId, CourseId, Tier, IssueDate, ExpiryDate, QrData) " +
                "VALUES (@Code, @U, @C, 1, @Issue, @Expiry, @Qr)",
                DBHelper.Param("@Code", code),
                DBHelper.Param("@U", userId),
                DBHelper.Param("@C", courseId),
                DBHelper.Param("@Issue", issue),
                DBHelper.Param("@Expiry", issue.AddYears(2)),
                DBHelper.Param("@Qr", qrData));

            return code;
        }

        public static bool IsTier2Eligible(int userId, int courseId)
        {
            DataRow c = GetCertificate(userId, courseId);
            if (c == null) return false;
            int tier = Convert.ToInt32(c["Tier"]);
            DateTime expiry = Convert.ToDateTime(c["ExpiryDate"]);
            DateTime issue = Convert.ToDateTime(c["IssueDate"]);
            return tier == 1 && expiry > DateTime.Now && issue <= DateTime.Now.AddMonths(-6);
        }

        /// <summary>Tier 2 replaces Tier 1 in place and resets the 2-year expiry.</summary>
        public static void UpgradeToTier2(int userId, int courseId)
        {
            DateTime issue = DateTime.Now;
            DBHelper.ExecuteNonQuery(
                "UPDATE Certificates SET Tier=2, IssueDate=@Issue, ExpiryDate=@Expiry " +
                "WHERE UserId=@U AND CourseId=@C",
                DBHelper.Param("@Issue", issue), DBHelper.Param("@Expiry", issue.AddYears(2)),
                DBHelper.Param("@U", userId), DBHelper.Param("@C", courseId));
        }

        public static bool IsTier3Eligible(int userId, int courseId)
        {
            DataRow c = GetCertificate(userId, courseId);
            if (c == null) return false;
            return Convert.ToInt32(c["Tier"]) >= 2 && Convert.ToDateTime(c["ExpiryDate"]) > DateTime.Now;
        }

        public static string TierName(int tier)
        {
            if (tier == 2) return "Certificate of Completion";
            if (tier == 3) return "Government-Recognised Badge";
            return "Certificate of Participation";
        }

        /// <summary>Renews a certificate (resets the 2-year expiry). Returns its tier.</summary>
        public static int RenewCertificate(int userId, int courseId)
        {
            DataRow c = GetCertificate(userId, courseId);
            if (c == null) return 0;

            DBHelper.ExecuteNonQuery(
                "UPDATE Certificates SET ExpiryDate=@E WHERE UserId=@U AND CourseId=@C",
                DBHelper.Param("@E", DateTime.Now.AddYears(2)),
                DBHelper.Param("@U", userId),
                DBHelper.Param("@C", courseId));

            return Convert.ToInt32(c["Tier"]);
        }
    }
}