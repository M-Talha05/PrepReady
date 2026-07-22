using System;
using System.Data;
using PrepReady.Helpers;

namespace PrepReady.Helpers
{
    /// <summary>
    /// Admin-only data operations. Thin wrappers over DBHelper with parameterized SQL.
    /// </summary>
    public static class AdminService
    {
        // ---------------- Dashboard ----------------
        public static DataRow GetStats()
        {
            return DBHelper.ExecuteSingleRow(
                "SELECT " +
                " (SELECT COUNT(*) FROM Users)              AS Users, " +
                " (SELECT COUNT(*) FROM Courses)            AS Courses, " +
                " (SELECT COUNT(*) FROM Lessons)            AS Lessons, " +
                " (SELECT COUNT(*) FROM Quizzes)            AS Quizzes, " +
                " (SELECT COUNT(*) FROM Certificates)       AS Certificates, " +
                " (SELECT COUNT(*) FROM Badges)             AS Badges, " +
                " (SELECT COUNT(*) FROM Registry)           AS Registry, " +
                " (SELECT COUNT(*) FROM RedemptionPartners) AS Partners, " +
                " (SELECT COUNT(*) FROM Redemptions)        AS Redemptions");
        }

        // ---------------- Users ----------------
        public static DataTable GetUsers()
        {
            return DBHelper.ExecuteDataTable(
                "SELECT UserId, FullName, Email, Role, IsActive, IsEmailVerified, " +
                "       PointBalance, RegistrationDate " +
                "FROM Users ORDER BY UserId");
        }

        public static void UpdateUser(int userId, string fullName, string role, bool isActive)
        {
            DBHelper.ExecuteNonQuery(
                "UPDATE Users SET FullName=@N, Role=@R, IsActive=@A WHERE UserId=@U",
                DBHelper.Param("@N", fullName),
                DBHelper.Param("@R", role),
                DBHelper.Param("@A", isActive),
                DBHelper.Param("@U", userId));
        }

        public static void AdjustPoints(int userId, int delta, string reason)
        {
            PointsService.Award(userId, delta, reason);
        }

        // Removes a user and every row that references them, FK-safe (child -> parent).
        public static void DeleteUser(int userId)
        {
            DBHelper.ExecuteNonQuery("DELETE FROM RememberTokens    WHERE UserId=@U", DBHelper.Param("@U", userId));   // EX-16
            DBHelper.ExecuteNonQuery("DELETE FROM Registry          WHERE UserId=@U", DBHelper.Param("@U", userId));
            DBHelper.ExecuteNonQuery(
                "DELETE FROM Badges WHERE CertificateId IN (SELECT CertificateId FROM Certificates WHERE UserId=@U)",
                DBHelper.Param("@U", userId));
            DBHelper.ExecuteNonQuery("DELETE FROM Notifications     WHERE UserId=@U", DBHelper.Param("@U", userId));
            DBHelper.ExecuteNonQuery(
                "DELETE FROM ContactReplies WHERE MessageId IN (SELECT MessageId FROM ContactMessages WHERE UserId=@U)",
                DBHelper.Param("@U", userId));
            DBHelper.ExecuteNonQuery("DELETE FROM ContactMessages   WHERE UserId=@U", DBHelper.Param("@U", userId));
            DBHelper.ExecuteNonQuery("DELETE FROM CourseReviews     WHERE UserId=@U", DBHelper.Param("@U", userId));
            DBHelper.ExecuteNonQuery("DELETE FROM Bookmarks         WHERE UserId=@U", DBHelper.Param("@U", userId));
            DBHelper.ExecuteNonQuery("DELETE FROM Redemptions       WHERE UserId=@U", DBHelper.Param("@U", userId));
            DBHelper.ExecuteNonQuery("DELETE FROM PointTransactions WHERE UserId=@U", DBHelper.Param("@U", userId));
            DBHelper.ExecuteNonQuery("DELETE FROM LessonProgress    WHERE UserId=@U", DBHelper.Param("@U", userId));
            DBHelper.ExecuteNonQuery("DELETE FROM QuizAttempts      WHERE UserId=@U", DBHelper.Param("@U", userId));
            DBHelper.ExecuteNonQuery("DELETE FROM Deployments       WHERE UserId=@U", DBHelper.Param("@U", userId));
            DBHelper.ExecuteNonQuery("DELETE FROM CommunityWork     WHERE UserId=@U", DBHelper.Param("@U", userId));
            DBHelper.ExecuteNonQuery("DELETE FROM Certificates      WHERE UserId=@U", DBHelper.Param("@U", userId));
            DBHelper.ExecuteNonQuery("DELETE FROM Enrollments       WHERE UserId=@U", DBHelper.Param("@U", userId));
            DBHelper.ExecuteNonQuery("DELETE FROM Users             WHERE UserId=@U", DBHelper.Param("@U", userId));
        }

        // ---------------- Redemption partners ----------------
        public static DataTable GetPartners()
        {
            return DBHelper.ExecuteDataTable(
                "SELECT PartnerId, Name, PartnerType, VoucherTitle, PointCost, IsActive " +
                "FROM RedemptionPartners ORDER BY PartnerId");
        }

        public static void InsertPartner(string name, string type, string voucher, int cost, bool active)
        {
            DBHelper.ExecuteNonQuery(
                "INSERT INTO RedemptionPartners (Name, PartnerType, VoucherTitle, PointCost, IsActive) " +
                "VALUES (@N,@T,@V,@C,@A)",
                DBHelper.Param("@N", name), DBHelper.Param("@T", type),
                DBHelper.Param("@V", voucher), DBHelper.Param("@C", cost),
                DBHelper.Param("@A", active));
        }

        public static void UpdatePartner(int id, string name, string type, string voucher, int cost, bool active)
        {
            DBHelper.ExecuteNonQuery(
                "UPDATE RedemptionPartners SET Name=@N, PartnerType=@T, VoucherTitle=@V, " +
                "PointCost=@C, IsActive=@A WHERE PartnerId=@P",
                DBHelper.Param("@N", name), DBHelper.Param("@T", type),
                DBHelper.Param("@V", voucher), DBHelper.Param("@C", cost),
                DBHelper.Param("@A", active), DBHelper.Param("@P", id));
        }

        public static void DeletePartner(int id)
        {
            DBHelper.ExecuteNonQuery("DELETE FROM Redemptions WHERE PartnerId=@P", DBHelper.Param("@P", id));
            DBHelper.ExecuteNonQuery("DELETE FROM RedemptionPartners WHERE PartnerId=@P", DBHelper.Param("@P", id));
        }

        // ---------------- Courses ----------------
        public static DataTable GetCourses()
        {
            return DBHelper.ExecuteDataTable(
                "SELECT c.CourseId, c.CategoryName, c.Title, c.GovPartner, c.PassingMark, c.IsPublished, " +
                " (SELECT COUNT(*) FROM Lessons l WHERE l.CourseId=c.CourseId) AS LessonCount " +
                "FROM Courses c ORDER BY c.CourseId");
        }

        public static DataRow GetCourse(int id)
        {
            return DBHelper.ExecuteSingleRow(
                "SELECT CourseId, CategoryName, Title, Description, GovPartner, PassingMark, IsPublished " +
                "FROM Courses WHERE CourseId=@C", DBHelper.Param("@C", id));
        }

        public static void InsertCourse(string cat, string title, string desc, string gov, int pass, bool pub)
        {
            DBHelper.ExecuteNonQuery(
                "INSERT INTO Courses (CategoryName, Title, Description, GovPartner, PassingMark, IsPublished) " +
                "VALUES (@Cat,@T,@D,@G,@P,@Pub)",
                DBHelper.Param("@Cat", cat), DBHelper.Param("@T", title),
                DBHelper.Param("@D", desc), DBHelper.Param("@G", gov),
                DBHelper.Param("@P", pass), DBHelper.Param("@Pub", pub));
        }

        public static void UpdateCourse(int id, string cat, string title, string desc, string gov, int pass, bool pub)
        {
            DBHelper.ExecuteNonQuery(
                "UPDATE Courses SET CategoryName=@Cat, Title=@T, Description=@D, GovPartner=@G, " +
                "PassingMark=@P, IsPublished=@Pub WHERE CourseId=@C",
                DBHelper.Param("@Cat", cat), DBHelper.Param("@T", title),
                DBHelper.Param("@D", desc), DBHelper.Param("@G", gov),
                DBHelper.Param("@P", pass), DBHelper.Param("@Pub", pub),
                DBHelper.Param("@C", id));
        }

        // True if anything references this course (so we block deletion and ask the
        // admin to clear dependents first, keeping referential integrity intact).
        public static bool CourseHasDependents(int id)
        {
            object n = DBHelper.ExecuteScalar(
                "SELECT (SELECT COUNT(*) FROM Lessons        WHERE CourseId=@C) + " +
                "       (SELECT COUNT(*) FROM Enrollments    WHERE CourseId=@C) + " +
                "       (SELECT COUNT(*) FROM Certificates   WHERE CourseId=@C) + " +
                "       (SELECT COUNT(*) FROM QuizAttempts   WHERE CourseId=@C) + " +
                "       (SELECT COUNT(*) FROM LessonProgress WHERE CourseId=@C) + " +
                "       (SELECT COUNT(*) FROM Deployments    WHERE CourseId=@C)",
                DBHelper.Param("@C", id));
            return Convert.ToInt32(n) > 0;
        }

        public static void DeleteCourse(int id)
        {
            DBHelper.ExecuteNonQuery("DELETE FROM Courses WHERE CourseId=@C", DBHelper.Param("@C", id));
        }

        // ---------------- Lessons ----------------
        public static DataTable GetCourseList()
        {
            return DBHelper.ExecuteDataTable("SELECT CourseId, Title FROM Courses ORDER BY Title");
        }

        public static DataTable GetLessons(int courseId)
        {
            return DBHelper.ExecuteDataTable(
                "SELECT l.LessonId, l.Title, l.MediaUrl, l.SortOrder, " +
                " (SELECT COUNT(*) FROM Quizzes q WHERE q.LessonId=l.LessonId) AS QuizCount " +
                "FROM Lessons l WHERE l.CourseId=@C ORDER BY l.SortOrder, l.LessonId",
                DBHelper.Param("@C", courseId));
        }

        public static DataRow GetLesson(int id)
        {
            return DBHelper.ExecuteSingleRow(
                "SELECT LessonId, CourseId, Title, BodyHtml, MediaUrl, SortOrder " +
                "FROM Lessons WHERE LessonId=@L", DBHelper.Param("@L", id));
        }

        public static void InsertLesson(int courseId, string title, string body, string media, int sort)
        {
            DBHelper.ExecuteNonQuery(
                "INSERT INTO Lessons (CourseId, Title, BodyHtml, MediaUrl, SortOrder) " +
                "VALUES (@C,@T,@B,@M,@S)",
                DBHelper.Param("@C", courseId), DBHelper.Param("@T", title),
                DBHelper.Param("@B", body), DBHelper.Param("@M", media),
                DBHelper.Param("@S", sort));
        }

        public static void UpdateLesson(int id, string title, string body, string media, int sort)
        {
            DBHelper.ExecuteNonQuery(
                "UPDATE Lessons SET Title=@T, BodyHtml=@B, MediaUrl=@M, SortOrder=@S WHERE LessonId=@L",
                DBHelper.Param("@T", title), DBHelper.Param("@B", body),
                DBHelper.Param("@M", media), DBHelper.Param("@S", sort),
                DBHelper.Param("@L", id));
        }

        // Removes the lesson and everything that hangs off it, FK-safe.
        public static void DeleteLesson(int id)
        {
            DBHelper.ExecuteNonQuery("DELETE FROM Quizzes        WHERE LessonId=@L", DBHelper.Param("@L", id));
            DBHelper.ExecuteNonQuery("DELETE FROM LessonProgress WHERE LessonId=@L", DBHelper.Param("@L", id));
            DBHelper.ExecuteNonQuery("DELETE FROM QuizAttempts   WHERE LessonId=@L", DBHelper.Param("@L", id));
            DBHelper.ExecuteNonQuery("DELETE FROM Lessons        WHERE LessonId=@L", DBHelper.Param("@L", id));
        }

        // ---------------- Quizzes ----------------
        public static DataTable GetLessonList()
        {
            return DBHelper.ExecuteDataTable(
                "SELECT l.LessonId, (c.Title + ' — ' + l.Title) AS Label " +
                "FROM Lessons l INNER JOIN Courses c ON c.CourseId=l.CourseId " +
                "ORDER BY c.Title, l.SortOrder, l.LessonId");
        }

        public static DataTable GetQuizzes(int lessonId)
        {
            return DBHelper.ExecuteDataTable(
                "SELECT QuizId, Question, CorrectOption, IsFinalExam FROM Quizzes " +
                "WHERE LessonId=@L ORDER BY IsFinalExam, QuizId",
                DBHelper.Param("@L", lessonId));
        }

        public static DataRow GetQuiz(int id)
        {
            return DBHelper.ExecuteSingleRow(
                "SELECT QuizId, LessonId, Question, OptionA, OptionB, OptionC, OptionD, " +
                "CorrectOption, IsFinalExam FROM Quizzes WHERE QuizId=@Q",
                DBHelper.Param("@Q", id));
        }

        public static void InsertQuiz(int lessonId, string q, string a, string b, string c, string d,
                                      string correct, bool isFinal)
        {
            DBHelper.ExecuteNonQuery(
                "INSERT INTO Quizzes (LessonId, Question, OptionA, OptionB, OptionC, OptionD, CorrectOption, IsFinalExam) " +
                "VALUES (@L,@Q,@A,@B,@C,@D,@Correct,@F)",
                DBHelper.Param("@L", lessonId), DBHelper.Param("@Q", q),
                DBHelper.Param("@A", a), DBHelper.Param("@B", b),
                DBHelper.Param("@C", string.IsNullOrWhiteSpace(c) ? null : c),
                DBHelper.Param("@D", string.IsNullOrWhiteSpace(d) ? null : d),
                DBHelper.Param("@Correct", correct), DBHelper.Param("@F", isFinal));
        }

        public static void UpdateQuiz(int id, string q, string a, string b, string c, string d,
                                      string correct, bool isFinal)
        {
            DBHelper.ExecuteNonQuery(
                "UPDATE Quizzes SET Question=@Q, OptionA=@A, OptionB=@B, OptionC=@C, OptionD=@D, " +
                "CorrectOption=@Correct, IsFinalExam=@F WHERE QuizId=@Id",
                DBHelper.Param("@Q", q), DBHelper.Param("@A", a), DBHelper.Param("@B", b),
                DBHelper.Param("@C", string.IsNullOrWhiteSpace(c) ? null : c),
                DBHelper.Param("@D", string.IsNullOrWhiteSpace(d) ? null : d),
                DBHelper.Param("@Correct", correct), DBHelper.Param("@F", isFinal),
                DBHelper.Param("@Id", id));
        }

        public static void DeleteQuiz(int id)
        {
            DBHelper.ExecuteNonQuery("DELETE FROM Quizzes WHERE QuizId=@Q", DBHelper.Param("@Q", id));
        }

        // ---------------- Credentials ----------------
        public static DataTable GetCertificates()
        {
            return DBHelper.ExecuteDataTable(
                "SELECT c.CertificateId, u.FullName, co.Title AS Course, c.Tier, c.CertCode, " +
                "       c.IssueDate, c.ExpiryDate " +
                "FROM Certificates c " +
                "INNER JOIN Users u    ON u.UserId   = c.UserId " +
                "INNER JOIN Courses co ON co.CourseId = c.CourseId " +
                "ORDER BY c.CertificateId");
        }

        public static DataTable GetBadges()
        {
            return DBHelper.ExecuteDataTable(
                "SELECT b.BadgeId, u.FullName, b.EndorsingAgency, b.IssueDate, b.ExpiryDate " +
                "FROM Badges b " +
                "INNER JOIN Certificates c ON c.CertificateId = b.CertificateId " +
                "INNER JOIN Users u        ON u.UserId        = c.UserId " +
                "ORDER BY b.BadgeId");
        }

        public static DataTable GetRegistry()
        {
            return DBHelper.ExecuteDataTable(
                "SELECT r.RegistryId, u.FullName, r.RecognisedField, r.EndorsingAgency, " +
                "       r.IssueDate, r.ExpiryDate " +
                "FROM Registry r INNER JOIN Users u ON u.UserId = r.UserId " +
                "ORDER BY r.RegistryId");
        }

        // Revoking a certificate also removes any badge and public registry entry
        // derived from it (FK-safe order).
        public static void RevokeCertificate(int certId)
        {
            DBHelper.ExecuteNonQuery(
                "DELETE FROM Registry WHERE BadgeId IN (SELECT BadgeId FROM Badges WHERE CertificateId=@C)",
                DBHelper.Param("@C", certId));
            DBHelper.ExecuteNonQuery("DELETE FROM Badges WHERE CertificateId=@C", DBHelper.Param("@C", certId));
            DBHelper.ExecuteNonQuery("DELETE FROM Certificates WHERE CertificateId=@C", DBHelper.Param("@C", certId));
        }

        // Removes a public registry entry only (the badge/certificate remain).
        public static void DeleteRegistryEntry(int registryId)
        {
            DBHelper.ExecuteNonQuery("DELETE FROM Registry WHERE RegistryId=@R", DBHelper.Param("@R", registryId));
        }
    }
}