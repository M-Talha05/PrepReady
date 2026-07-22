using System;
using System.Data;

namespace PrepReady.Helpers
{
    /// <summary>
    /// Tracks consecutive-day login streaks. Awards a 30-point bonus every time
    /// the streak reaches a multiple of 7 days. Called once per login.
    /// </summary>
    public static class StreakService
    {
        public static void RegisterLogin(int userId)
        {
            DataRow u = DBHelper.ExecuteSingleRow(
                "SELECT LastLoginDate, LoginStreak FROM Users WHERE UserId=@U",
                DBHelper.Param("@U", userId));
            if (u == null) return;

            DateTime today = DateTime.Today;
            int streak;
            object last = u["LastLoginDate"];

            if (last == null || last == DBNull.Value)
            {
                streak = 1;
            }
            else
            {
                DateTime lastDate = Convert.ToDateTime(last).Date;
                if (lastDate == today) return;                 // already counted today
                if (lastDate == today.AddDays(-1)) streak = Convert.ToInt32(u["LoginStreak"]) + 1; // consecutive
                else streak = 1;                               // streak broken -> restart
            }

            DBHelper.ExecuteNonQuery(
                "UPDATE Users SET LastLoginDate=@Now, LoginStreak=@S WHERE UserId=@U",
                DBHelper.Param("@Now", DateTime.Now),
                DBHelper.Param("@S", streak),
                DBHelper.Param("@U", userId));

            if (streak % 7 == 0)
                PointsService.Award(userId, 30, "7-day login streak bonus");
        }
    }
}