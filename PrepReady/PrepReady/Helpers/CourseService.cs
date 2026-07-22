using System;
using System.Data;

namespace PrepReady.Helpers
{
    /// <summary>
    /// Data access for the catalogue, course detail, lesson viewer and
    /// member dashboard. All queries are parameterized via DBHelper.
    /// </summary>
    public static class CourseService
    {
        public static DataTable GetCategories()
        {
            return DBHelper.ExecuteDataTable(
                "SELECT DISTINCT CategoryName FROM Courses WHERE IsPublished = 1 ORDER BY CategoryName");
        }

        /// <summary>Published courses, optionally filtered by category (null/empty = all).</summary>
        public static DataTable GetPublishedCourses(string category)
        {
            string sql =
                "SELECT c.CourseId, c.CategoryName, c.Title, c.Description, c.GovPartner, c.PassingMark, " +
                "  (SELECT COUNT(*) FROM Lessons l WHERE l.CourseId = c.CourseId) AS LessonCount " +
                "FROM Courses c WHERE c.IsPublished = 1 ";

            if (!string.IsNullOrEmpty(category))
            {
                sql += "AND c.CategoryName = @Cat ORDER BY c.Title";
                return DBHelper.ExecuteDataTable(sql, DBHelper.Param("@Cat", category));
            }

            sql += "ORDER BY c.CategoryName, c.Title";
            return DBHelper.ExecuteDataTable(sql);
        }

        public static DataRow GetCourse(int courseId)
        {
            return DBHelper.ExecuteSingleRow(
                "SELECT * FROM Courses WHERE CourseId = @Id", DBHelper.Param("@Id", courseId));
        }

        public static DataTable GetLessons(int courseId)
        {
            return DBHelper.ExecuteDataTable(
                "SELECT LessonId, CourseId, Title, BodyHtml, MediaUrl, SortOrder " +
                "FROM Lessons WHERE CourseId = @Id ORDER BY SortOrder, LessonId",
                DBHelper.Param("@Id", courseId));
        }

        public static DataRow GetLesson(int lessonId)
        {
            return DBHelper.ExecuteSingleRow(
                "SELECT * FROM Lessons WHERE LessonId = @Id", DBHelper.Param("@Id", lessonId));
        }

        public static bool IsEnrolled(int userId, int courseId)
        {
            int n = Convert.ToInt32(DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Enrollments WHERE UserId = @U AND CourseId = @C",
                DBHelper.Param("@U", userId), DBHelper.Param("@C", courseId)));
            return n > 0;
        }

        public static void Enroll(int userId, int courseId)
        {
            DBHelper.ExecuteNonQuery(
                "IF NOT EXISTS (SELECT 1 FROM Enrollments WHERE UserId=@U AND CourseId=@C) " +
                "INSERT INTO Enrollments (UserId, CourseId, Status) VALUES (@U, @C, 'Enrolled')",
                DBHelper.Param("@U", userId), DBHelper.Param("@C", courseId));
        }

        public static void MarkLessonComplete(int userId, int courseId, int lessonId)
        {
            DBHelper.ExecuteNonQuery(
                "IF NOT EXISTS (SELECT 1 FROM LessonProgress WHERE UserId=@U AND LessonId=@L) " +
                "INSERT INTO LessonProgress (UserId, CourseId, LessonId) VALUES (@U, @C, @L)",
                DBHelper.Param("@U", userId), DBHelper.Param("@C", courseId), DBHelper.Param("@L", lessonId));

            // First activity moves the enrollment from 'Enrolled' to 'InProgress'.
            DBHelper.ExecuteNonQuery(
                "UPDATE Enrollments SET Status='InProgress' WHERE UserId=@U AND CourseId=@C AND Status='Enrolled'",
                DBHelper.Param("@U", userId), DBHelper.Param("@C", courseId));
        }

        public static bool IsLessonComplete(int userId, int lessonId)
        {
            int n = Convert.ToInt32(DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM LessonProgress WHERE UserId=@U AND LessonId=@L",
                DBHelper.Param("@U", userId), DBHelper.Param("@L", lessonId)));
            return n > 0;
        }

        public static int CountLessons(int courseId)
        {
            return Convert.ToInt32(DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Lessons WHERE CourseId=@C", DBHelper.Param("@C", courseId)));
        }

        public static int CountCompletedLessons(int userId, int courseId)
        {
            return Convert.ToInt32(DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM LessonProgress WHERE UserId=@U AND CourseId=@C",
                DBHelper.Param("@U", userId), DBHelper.Param("@C", courseId)));
        }

        public static DataTable GetUserEnrollments(int userId)
        {
            string sql =
                "SELECT e.CourseId, c.Title, c.CategoryName, c.GovPartner, e.Status, " +
                "  (SELECT COUNT(*) FROM Lessons l WHERE l.CourseId = c.CourseId) AS TotalLessons, " +
                "  (SELECT COUNT(*) FROM LessonProgress lp WHERE lp.UserId = e.UserId AND lp.CourseId = c.CourseId) AS CompletedLessons " +
                "FROM Enrollments e INNER JOIN Courses c ON c.CourseId = e.CourseId " +
                "WHERE e.UserId = @U ORDER BY e.EnrolledDate DESC";
            return DBHelper.ExecuteDataTable(sql, DBHelper.Param("@U", userId));
        }

        public static int GetPointBalance(int userId)
        {
            object o = DBHelper.ExecuteScalar(
                "SELECT PointBalance FROM Users WHERE UserId=@U", DBHelper.Param("@U", userId));
            return o == null ? 0 : Convert.ToInt32(o);
        }

        public static int CountCertificates(int userId)
        {
            return Convert.ToInt32(DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Certificates WHERE UserId=@U", DBHelper.Param("@U", userId)));
        }

        /// <summary>First lesson (by order) the user hasn't completed; else the first lesson; else 0.</summary>
        public static int GetNextLessonId(int userId, int courseId)
        {
            object o = DBHelper.ExecuteScalar(
                "SELECT TOP 1 l.LessonId FROM Lessons l " +
                "WHERE l.CourseId=@C AND l.LessonId NOT IN " +
                "  (SELECT lp.LessonId FROM LessonProgress lp WHERE lp.UserId=@U AND lp.CourseId=@C) " +
                "ORDER BY l.SortOrder, l.LessonId",
                DBHelper.Param("@U", userId), DBHelper.Param("@C", courseId));

            if (o != null) return Convert.ToInt32(o);

            // All complete -> just go to the first lesson.
            object first = DBHelper.ExecuteScalar(
                "SELECT TOP 1 LessonId FROM Lessons WHERE CourseId=@C ORDER BY SortOrder, LessonId",
                DBHelper.Param("@C", courseId));
            return first == null ? 0 : Convert.ToInt32(first);
        }

        public static System.Collections.Generic.HashSet<int> GetCompletedLessonIds(int userId, int courseId)
        {
            var set = new System.Collections.Generic.HashSet<int>();
            DataTable dt = DBHelper.ExecuteDataTable(
                "SELECT LessonId FROM LessonProgress WHERE UserId=@U AND CourseId=@C",
                DBHelper.Param("@U", userId), DBHelper.Param("@C", courseId));
            foreach (DataRow r in dt.Rows) set.Add(Convert.ToInt32(r["LessonId"]));
            return set;
        }
    }
}