using System;
using System.Data;

namespace PrepReady.Helpers
{
    public static class NotificationService
    {
        public static void Notify(int userId, string title, string message, string linkUrl)
        {
            DBHelper.ExecuteNonQuery(
                "INSERT INTO Notifications (UserId, Title, Message, LinkUrl) VALUES (@U, @T, @M, @L)",
                DBHelper.Param("@U", userId),
                DBHelper.Param("@T", title),
                DBHelper.Param("@M", message),
                DBHelper.Param("@L", linkUrl));
        }

        public static int CountUnread(int userId)
        {
            object o = DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Notifications WHERE UserId = @U AND IsRead = 0",
                DBHelper.Param("@U", userId));
            return (o == null || o == DBNull.Value) ? 0 : Convert.ToInt32(o);
        }

        public static DataTable GetRecent(int userId, int top)
        {
            return DBHelper.ExecuteDataTable(
                "SELECT TOP (@Top) NotificationId, Title, Message, LinkUrl, IsRead, CreatedDate " +
                "FROM Notifications WHERE UserId = @U ORDER BY CreatedDate DESC",
                DBHelper.Param("@Top", top),
                DBHelper.Param("@U", userId));
        }

        public static DataTable GetAll(int userId)
        {
            return DBHelper.ExecuteDataTable(
                "SELECT NotificationId, Title, Message, LinkUrl, IsRead, CreatedDate " +
                "FROM Notifications WHERE UserId = @U ORDER BY CreatedDate DESC",
                DBHelper.Param("@U", userId));
        }

        public static string GetLink(int notificationId, int userId)
        {
            object o = DBHelper.ExecuteScalar(
                "SELECT LinkUrl FROM Notifications WHERE NotificationId = @N AND UserId = @U",
                DBHelper.Param("@N", notificationId),
                DBHelper.Param("@U", userId));
            return (o == null || o == DBNull.Value) ? null : o.ToString();
        }

        public static void MarkRead(int notificationId, int userId)
        {
            DBHelper.ExecuteNonQuery(
                "UPDATE Notifications SET IsRead = 1 WHERE NotificationId = @N AND UserId = @U",
                DBHelper.Param("@N", notificationId),
                DBHelper.Param("@U", userId));
        }

        public static void MarkAllRead(int userId)
        {
            DBHelper.ExecuteNonQuery(
                "UPDATE Notifications SET IsRead = 1 WHERE UserId = @U AND IsRead = 0",
                DBHelper.Param("@U", userId));
        }
    }
}