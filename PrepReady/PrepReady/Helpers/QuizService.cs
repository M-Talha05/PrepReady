using System;
using System.Collections.Generic;
using System.Data;

namespace PrepReady.Helpers
{
    /// <summary>
    /// Quiz/exam data access: question retrieval, attempt recording, and the
    /// gating logic for final-exam eligibility.
    /// </summary>
    public static class QuizService
    {
        public static DataTable GetLessonQuestions(int lessonId)
        {
            return DBHelper.ExecuteDataTable(
                "SELECT QuizId, Question, OptionA, OptionB, OptionC, OptionD, CorrectOption " +
                "FROM Quizzes WHERE LessonId=@L AND IsFinalExam=0 ORDER BY QuizId",
                DBHelper.Param("@L", lessonId));
        }

        public static DataTable GetFinalExamQuestions(int courseId)
        {
            return DBHelper.ExecuteDataTable(
                "SELECT q.QuizId, q.Question, q.OptionA, q.OptionB, q.OptionC, q.OptionD, q.CorrectOption " +
                "FROM Quizzes q INNER JOIN Lessons l ON l.LessonId = q.LessonId " +
                "WHERE l.CourseId=@C AND q.IsFinalExam=1 ORDER BY q.QuizId",
                DBHelper.Param("@C", courseId));
        }

        public static int CountAttempts(int userId, int lessonId)
        {
            return Convert.ToInt32(DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM QuizAttempts WHERE UserId=@U AND LessonId=@L AND IsFinalExam=0",
                DBHelper.Param("@U", userId), DBHelper.Param("@L", lessonId)));
        }

        public static bool HasPassedQuiz(int userId, int lessonId)
        {
            return Convert.ToInt32(DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM QuizAttempts WHERE UserId=@U AND LessonId=@L AND IsFinalExam=0 AND Passed=1",
                DBHelper.Param("@U", userId), DBHelper.Param("@L", lessonId))) > 0;
        }

        public static bool HasPassedFinalExam(int userId, int courseId)
        {
            return Convert.ToInt32(DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM QuizAttempts WHERE UserId=@U AND CourseId=@C AND IsFinalExam=1 AND Passed=1",
                DBHelper.Param("@U", userId), DBHelper.Param("@C", courseId))) > 0;
        }

        public static void RecordAttempt(int userId, int courseId, int? lessonId, bool isFinalExam,
                                         int score, int total, int percentage, bool passed)
        {
            DBHelper.ExecuteNonQuery(
                "INSERT INTO QuizAttempts (UserId, CourseId, LessonId, IsFinalExam, Score, TotalQuestions, Percentage, Passed) " +
                "VALUES (@U, @C, @L, @F, @S, @T, @P, @Pass)",
                DBHelper.Param("@U", userId),
                DBHelper.Param("@C", courseId),
                DBHelper.Param("@L", lessonId.HasValue ? (object)lessonId.Value : null),
                DBHelper.Param("@F", isFinalExam),
                DBHelper.Param("@S", score),
                DBHelper.Param("@T", total),
                DBHelper.Param("@P", percentage),
                DBHelper.Param("@Pass", passed));
        }

        public static bool AllLessonsComplete(int userId, int courseId)
        {
            int total = CourseService.CountLessons(courseId);
            int done = CourseService.CountCompletedLessons(userId, courseId);
            return total > 0 && done >= total;
        }

        /// <summary>True when every lesson that HAS a sub-quiz has a passing attempt.</summary>
        public static bool AllQuizzesPassed(int userId, int courseId)
        {
            int remaining = Convert.ToInt32(DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Lessons l WHERE l.CourseId=@C " +
                "AND EXISTS (SELECT 1 FROM Quizzes q WHERE q.LessonId=l.LessonId AND q.IsFinalExam=0) " +
                "AND NOT EXISTS (SELECT 1 FROM QuizAttempts a WHERE a.UserId=@U AND a.LessonId=l.LessonId " +
                "                AND a.IsFinalExam=0 AND a.Passed=1)",
                DBHelper.Param("@U", userId), DBHelper.Param("@C", courseId)));
            return remaining == 0;
        }

        public static void CompleteCourse(int userId, int courseId, int score)
        {
            DBHelper.ExecuteNonQuery(
                "UPDATE Enrollments SET Status='Completed', Score=@S, CompletedDate=GETDATE() " +
                "WHERE UserId=@U AND CourseId=@C",
                DBHelper.Param("@U", userId), DBHelper.Param("@C", courseId), DBHelper.Param("@S", score));
        }

        public static HashSet<int> GetPassedQuizLessonIds(int userId, int courseId)
        {
            var set = new HashSet<int>();
            DataTable dt = DBHelper.ExecuteDataTable(
                "SELECT DISTINCT LessonId FROM QuizAttempts " +
                "WHERE UserId=@U AND CourseId=@C AND IsFinalExam=0 AND Passed=1 AND LessonId IS NOT NULL",
                DBHelper.Param("@U", userId), DBHelper.Param("@C", courseId));
            foreach (DataRow r in dt.Rows) set.Add(Convert.ToInt32(r["LessonId"]));
            return set;
        }
    }
}