using System;
using System.Data;

namespace PrepReady.Helpers
{
    public static class ReportService
    {
        public static DataRow GetKpis()
        {
            return DBHelper.ExecuteSingleRow(
                "SELECT " +
                " (SELECT COUNT(*) FROM Users WHERE Role='Member')        AS Members, " +
                " (SELECT COUNT(*) FROM Courses WHERE IsPublished=1)      AS PublishedCourses, " +
                " (SELECT COUNT(*) FROM Certificates)                     AS Certificates, " +
                " (SELECT COUNT(*) FROM Registry)                         AS Registry, " +
                " (SELECT COUNT(*) FROM CourseReviews)                    AS Reviews");
        }

        public static int PointsAwarded()
        {
            object o = DBHelper.ExecuteScalar("SELECT ISNULL(SUM(Points),0) FROM PointTransactions WHERE Points > 0");
            return Convert.ToInt32(o);
        }

        public static int PointsSpent()
        {
            object o = DBHelper.ExecuteScalar("SELECT ISNULL(SUM(-Points),0) FROM PointTransactions WHERE Points < 0");
            return Convert.ToInt32(o);
        }

        public static DataTable GetCertificatesByTier()
        {
            return DBHelper.ExecuteDataTable(
                "SELECT Tier, COUNT(*) AS Cnt FROM Certificates GROUP BY Tier ORDER BY Tier");
        }

        // Last 6 calendar months of member registrations (yyyy-MM).
        public static DataTable GetMonthlyRegistrations()
        {
            return DBHelper.ExecuteDataTable(
                "SELECT CONVERT(char(7), RegistrationDate, 126) AS Ym, COUNT(*) AS Cnt " +
                "FROM Users " +
                "WHERE RegistrationDate >= DATEADD(MONTH, -5, CAST(GETDATE() AS DATE)) " +
                "GROUP BY CONVERT(char(7), RegistrationDate, 126) " +
                "ORDER BY Ym");
        }

        public static DataTable GetCoursePerformance()
        {
            return DBHelper.ExecuteDataTable(
                "SELECT c.CourseId, c.Title, " +
                " (SELECT COUNT(*) FROM Enrollments  e WHERE e.CourseId=c.CourseId)  AS Enrollments, " +
                " (SELECT COUNT(*) FROM Certificates ce WHERE ce.CourseId=c.CourseId) AS Certificates, " +
                " (SELECT COUNT(*) FROM CourseReviews r WHERE r.CourseId=c.CourseId)  AS Reviews, " +
                " ISNULL((SELECT AVG(CAST(Rating AS FLOAT)) FROM CourseReviews r WHERE r.CourseId=c.CourseId),0) AS AvgRating " +
                "FROM Courses c ORDER BY Enrollments DESC, c.Title");
        }
    }
}