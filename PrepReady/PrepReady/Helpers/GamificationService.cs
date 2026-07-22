using System;
using System.Data;

namespace PrepReady.Helpers
{
    /// <summary>Leaderboard, points history, badge collection, and achievement stats.</summary>
    public static class GamificationService
    {
        public static DataTable GetLeaderboard(int top)
        {
            if (top < 1) top = 20;                 // 'top' is an int, safe to inline
            return DBHelper.ExecuteDataTable(
                "SELECT TOP (" + top + ") FullName, PointBalance " +
                "FROM Users WHERE Role='Member' AND IsActive=1 " +
                "ORDER BY PointBalance DESC, FullName");
        }

        public static DataTable GetPointHistory(int userId)
        {
            return DBHelper.ExecuteDataTable(
                "SELECT Points, Reason, TxnDate FROM PointTransactions " +
                "WHERE UserId=@U ORDER BY TxnDate DESC",
                DBHelper.Param("@U", userId));
        }

        public static DataTable GetTier3Badges(int userId)
        {
            return DBHelper.ExecuteDataTable(
                "SELECT b.EndorsingAgency, b.IssueDate, b.ExpiryDate, co.Title AS CourseTitle " +
                "FROM Badges b " +
                "INNER JOIN Certificates c ON c.CertificateId = b.CertificateId " +
                "INNER JOIN Courses co ON co.CourseId = c.CourseId " +
                "WHERE c.UserId=@U ORDER BY b.IssueDate DESC",
                DBHelper.Param("@U", userId));
        }

        public static int GetLoginStreak(int userId)
        {
            object o = DBHelper.ExecuteScalar(
                "SELECT LoginStreak FROM Users WHERE UserId=@U", DBHelper.Param("@U", userId));
            return o == null ? 0 : Convert.ToInt32(o);
        }

        // ---- counts used to compute achievement badges ----
        public static int LessonsCompleted(int userId)
        {
            return Convert.ToInt32(DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM LessonProgress WHERE UserId=@U", DBHelper.Param("@U", userId)));
        }

        public static int QuizzesPassed(int userId)
        {
            return Convert.ToInt32(DBHelper.ExecuteScalar(
                "SELECT COUNT(DISTINCT LessonId) FROM QuizAttempts " +
                "WHERE UserId=@U AND IsFinalExam=0 AND Passed=1", DBHelper.Param("@U", userId)));
        }

        public static int CertificateCount(int userId)
        {
            return Convert.ToInt32(DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Certificates WHERE UserId=@U", DBHelper.Param("@U", userId)));
        }

        public static int CompletedCourses(int userId)
        {
            return Convert.ToInt32(DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Enrollments WHERE UserId=@U AND Status='Completed'",
                DBHelper.Param("@U", userId)));
        }
    }
}