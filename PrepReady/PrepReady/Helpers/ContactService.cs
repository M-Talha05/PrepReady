using System;
using System.Data;

namespace PrepReady.Helpers
{
    public static class ContactService
    {
        // Create a new message thread. userId is null for guests. Returns the new MessageId.
        public static int Submit(string fullName, string email, string subject, string body, int? userId)
        {
            object o = DBHelper.ExecuteScalar(
                "INSERT INTO ContactMessages (FullName, Email, Subject, Body, UserId, LastReplyDate) " +
                "VALUES (@N,@E,@S,@B,@U,GETDATE()); SELECT CAST(SCOPE_IDENTITY() AS INT);",
                DBHelper.Param("@N", fullName), DBHelper.Param("@E", email),
                DBHelper.Param("@S", subject), DBHelper.Param("@B", body),
                DBHelper.Param("@U", userId));
            return Convert.ToInt32(o);
        }

        // Admin/Officer inbox: every thread with reply count + last activity.
        public static DataTable GetAll()
        {
            return DBHelper.ExecuteDataTable(
                "SELECT m.MessageId, m.FullName, m.Email, m.Subject, m.Body, m.IsResolved, " +
                "       m.CreatedDate, m.UserId, " +
                "       ISNULL(m.LastReplyDate, m.CreatedDate) AS LastActivity, " +
                "       (SELECT COUNT(*) FROM ContactReplies r WHERE r.MessageId = m.MessageId) AS ReplyCount " +
                "FROM ContactMessages m " +
                "ORDER BY m.IsResolved ASC, ISNULL(m.LastReplyDate, m.CreatedDate) DESC");
        }

        public static DataRow GetMessage(int messageId)
        {
            return DBHelper.ExecuteSingleRow(
                "SELECT MessageId, FullName, Email, Subject, Body, IsResolved, CreatedDate, UserId " +
                "FROM ContactMessages WHERE MessageId=@Id",
                DBHelper.Param("@Id", messageId));
        }

        // The reply timeline (oldest first).
        public static DataTable GetThread(int messageId)
        {
            return DBHelper.ExecuteDataTable(
                "SELECT ReplyId, MessageId, SenderRole, SenderUserId, SenderName, Body, CreatedDate " +
                "FROM ContactReplies WHERE MessageId=@Id ORDER BY CreatedDate ASC, ReplyId ASC",
                DBHelper.Param("@Id", messageId));
        }

        // A registered user's own threads.
        public static DataTable GetThreadsForUser(int userId)
        {
            return DBHelper.ExecuteDataTable(
                "SELECT m.MessageId, m.Subject, m.IsResolved, m.CreatedDate, " +
                "       ISNULL(m.LastReplyDate, m.CreatedDate) AS LastActivity, " +
                "       (SELECT COUNT(*) FROM ContactReplies r WHERE r.MessageId = m.MessageId) AS ReplyCount " +
                "FROM ContactMessages m WHERE m.UserId=@U " +
                "ORDER BY ISNULL(m.LastReplyDate, m.CreatedDate) DESC",
                DBHelper.Param("@U", userId));
        }

        public static void AddReply(int messageId, string senderRole, int? senderUserId, string senderName, string body)
        {
            DBHelper.ExecuteNonQuery(
                "INSERT INTO ContactReplies (MessageId, SenderRole, SenderUserId, SenderName, Body) " +
                "VALUES (@M,@R,@U,@N,@B); " +
                "UPDATE ContactMessages SET LastReplyDate=GETDATE() WHERE MessageId=@M;",
                DBHelper.Param("@M", messageId), DBHelper.Param("@R", senderRole),
                DBHelper.Param("@U", senderUserId), DBHelper.Param("@N", senderName),
                DBHelper.Param("@B", body));
        }

        // Security: confirm the thread belongs to this user before showing/replying.
        public static bool IsOwner(int messageId, int userId)
        {
            object o = DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM ContactMessages WHERE MessageId=@M AND UserId=@U",
                DBHelper.Param("@M", messageId), DBHelper.Param("@U", userId));
            return Convert.ToInt32(o) > 0;
        }

        public static int CountUnresolved()
        {
            object o = DBHelper.ExecuteScalar("SELECT COUNT(*) FROM ContactMessages WHERE IsResolved=0");
            return Convert.ToInt32(o);
        }

        public static void SetResolved(int id, bool resolved)
        {
            DBHelper.ExecuteNonQuery("UPDATE ContactMessages SET IsResolved=@R WHERE MessageId=@Id",
                DBHelper.Param("@R", resolved), DBHelper.Param("@Id", id));
        }

        public static void Reopen(int id) { SetResolved(id, false); }

        public static void Delete(int id)
        {
            // Replies first (FK), then the message.
            DBHelper.ExecuteNonQuery("DELETE FROM ContactReplies  WHERE MessageId=@Id", DBHelper.Param("@Id", id));
            DBHelper.ExecuteNonQuery("DELETE FROM ContactMessages WHERE MessageId=@Id", DBHelper.Param("@Id", id));
        }
    }
}