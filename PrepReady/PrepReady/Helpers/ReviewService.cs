using System;
using System.Data;
using System.Text;

namespace PrepReady.Helpers
{
    public static class ReviewService
    {
        /// <summary>A member may review only a course they've completed (hold a certificate for).</summary>
        public static bool CanReview(int userId, int courseId)
        {
            object o = DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Certificates WHERE UserId=@U AND CourseId=@C",
                DBHelper.Param("@U", userId), DBHelper.Param("@C", courseId));
            return Convert.ToInt32(o) > 0;
        }

        public static DataRow GetUserReview(int userId, int courseId)
        {
            return DBHelper.ExecuteSingleRow(
                "SELECT ReviewId, Rating, Comment FROM CourseReviews WHERE UserId=@U AND CourseId=@C",
                DBHelper.Param("@U", userId), DBHelper.Param("@C", courseId));
        }

        /// <summary>Insert or update — one review per user/course (also enforced by a unique index).</summary>
        public static void Save(int userId, int courseId, int rating, string comment)
        {
            if (rating < 1) rating = 1;
            if (rating > 5) rating = 5;

            DataRow existing = GetUserReview(userId, courseId);
            if (existing == null)
            {
                DBHelper.ExecuteNonQuery(
                    "INSERT INTO CourseReviews (CourseId, UserId, Rating, Comment) VALUES (@C,@U,@R,@M)",
                    DBHelper.Param("@C", courseId), DBHelper.Param("@U", userId),
                    DBHelper.Param("@R", rating), DBHelper.Param("@M", comment));
            }
            else
            {
                DBHelper.ExecuteNonQuery(
                    "UPDATE CourseReviews SET Rating=@R, Comment=@M, CreatedDate=GETDATE() WHERE ReviewId=@Id",
                    DBHelper.Param("@R", rating), DBHelper.Param("@M", comment),
                    DBHelper.Param("@Id", Convert.ToInt32(existing["ReviewId"])));
            }
        }

        public static DataTable GetReviews(int courseId)
        {
            return DBHelper.ExecuteDataTable(
                "SELECT cr.Rating, cr.Comment, cr.CreatedDate, u.FullName " +
                "FROM CourseReviews cr INNER JOIN Users u ON u.UserId=cr.UserId " +
                "WHERE cr.CourseId=@C ORDER BY cr.CreatedDate DESC",
                DBHelper.Param("@C", courseId));
        }

        public static double GetAverage(int courseId)
        {
            object o = DBHelper.ExecuteScalar(
                "SELECT AVG(CAST(Rating AS FLOAT)) FROM CourseReviews WHERE CourseId=@C",
                DBHelper.Param("@C", courseId));
            return (o == null || o == DBNull.Value) ? 0.0 : Convert.ToDouble(o);
        }

        public static int GetCount(int courseId)
        {
            object o = DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM CourseReviews WHERE CourseId=@C",
                DBHelper.Param("@C", courseId));
            return Convert.ToInt32(o);
        }

        /// <summary>Returns a 5-glyph star string (filled to the rounded rating).</summary>
        public static string Stars(double rating)
        {
            int full = (int)Math.Round(rating);
            if (full < 0) full = 0;
            if (full > 5) full = 5;
            StringBuilder sb = new StringBuilder("<span class=\"pr-stars\">");
            for (int i = 1; i <= 5; i++) sb.Append(i <= full ? "\u2605" : "\u2606");
            sb.Append("</span>");
            return sb.ToString();
        }

        // ---- Admin moderation ----
        public static DataTable GetAllForAdmin()
        {
            return DBHelper.ExecuteDataTable(
                "SELECT cr.ReviewId, co.Title AS Course, u.FullName, cr.Rating, cr.Comment, cr.CreatedDate " +
                "FROM CourseReviews cr " +
                "INNER JOIN Courses co ON co.CourseId=cr.CourseId " +
                "INNER JOIN Users u   ON u.UserId  =cr.UserId " +
                "ORDER BY cr.CreatedDate DESC");
        }

        public static void Delete(int reviewId)
        {
            DBHelper.ExecuteNonQuery("DELETE FROM CourseReviews WHERE ReviewId=@R", DBHelper.Param("@R", reviewId));
        }
    }
}