using System;
using System.Data;

namespace PrepReady.Helpers
{
    public static class BookmarkService
    {
        public static bool IsBookmarked(int userId, int courseId)
        {
            object o = DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Bookmarks WHERE UserId=@U AND CourseId=@C",
                DBHelper.Param("@U", userId), DBHelper.Param("@C", courseId));
            return Convert.ToInt32(o) > 0;
        }

        // Returns the NEW state: true = now saved, false = removed.
        public static bool Toggle(int userId, int courseId)
        {
            if (IsBookmarked(userId, courseId))
            {
                DBHelper.ExecuteNonQuery(
                    "DELETE FROM Bookmarks WHERE UserId=@U AND CourseId=@C",
                    DBHelper.Param("@U", userId), DBHelper.Param("@C", courseId));
                return false;
            }
            DBHelper.ExecuteNonQuery(
                "INSERT INTO Bookmarks (UserId, CourseId) VALUES (@U, @C)",
                DBHelper.Param("@U", userId), DBHelper.Param("@C", courseId));
            return true;
        }

        public static void Remove(int userId, int courseId)
        {
            DBHelper.ExecuteNonQuery(
                "DELETE FROM Bookmarks WHERE UserId=@U AND CourseId=@C",
                DBHelper.Param("@U", userId), DBHelper.Param("@C", courseId));
        }

        public static int Count(int userId)
        {
            object o = DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Bookmarks WHERE UserId=@U", DBHelper.Param("@U", userId));
            return Convert.ToInt32(o);
        }

        // Saved (bookmarked) courses + display fields.
        // NOTE: CategoryName is a column on Courses (no separate Categories table).
        public static DataTable GetSavedCourses(int userId)
        {
            return DBHelper.ExecuteDataTable(
                "SELECT c.CourseId, c.Title, c.Description, c.GovPartner, c.CategoryName, " +
                "       (SELECT COUNT(*) FROM Lessons l WHERE l.CourseId = c.CourseId) AS LessonCount, " +
                "       b.CreatedDate AS SavedDate " +
                "FROM Bookmarks b " +
                "JOIN Courses c ON c.CourseId = b.CourseId " +
                "WHERE b.UserId=@U " +
                "ORDER BY b.CreatedDate DESC",
                DBHelper.Param("@U", userId));
        }

        // Enrolled / in-progress courses (de-duplicated per course) with progress counts.
        public static DataTable GetInProgressCourses(int userId)
        {
            return DBHelper.ExecuteDataTable(
                "SELECT c.CourseId, c.Title, c.CategoryName, " +
                "       (SELECT COUNT(*) FROM Lessons l WHERE l.CourseId = c.CourseId) AS TotalLessons, " +
                "       (SELECT COUNT(*) FROM LessonProgress lp WHERE lp.UserId=@U AND lp.CourseId=c.CourseId) AS DoneLessons " +
                "FROM Enrollments e " +
                "JOIN Courses c ON c.CourseId = e.CourseId " +
                "WHERE e.UserId=@U " +
                "GROUP BY c.CourseId, c.Title, c.CategoryName " +
                "ORDER BY MAX(e.EnrolledDate) DESC",
                DBHelper.Param("@U", userId));
        }
    }
}