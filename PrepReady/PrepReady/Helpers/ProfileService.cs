using System;
using System.Data;

namespace PrepReady.Helpers
{
    public static class ProfileService
    {
        public static DataRow GetProfile(int userId)
        {
            return DBHelper.ExecuteSingleRow(
                "SELECT UserId, FullName, Email, Bio, AvatarPath, PointBalance, Role, RegistrationDate " +
                "FROM Users WHERE UserId = @UserId",
                DBHelper.Param("@UserId", userId));
        }

        public static void UpdateProfile(int userId, string fullName, string bio)
        {
            DBHelper.ExecuteNonQuery(
                "UPDATE Users SET FullName = @FullName, Bio = @Bio WHERE UserId = @UserId",
                DBHelper.Param("@FullName", fullName),
                DBHelper.Param("@Bio", bio),
                DBHelper.Param("@UserId", userId));
        }

        public static void UpdateAvatar(int userId, string avatarPath)
        {
            DBHelper.ExecuteNonQuery(
                "UPDATE Users SET AvatarPath = @AvatarPath WHERE UserId = @UserId",
                DBHelper.Param("@AvatarPath", avatarPath),
                DBHelper.Param("@UserId", userId));
        }

        public static string GetAvatarPath(int userId)
        {
            object o = DBHelper.ExecuteScalar(
                "SELECT AvatarPath FROM Users WHERE UserId = @UserId",
                DBHelper.Param("@UserId", userId));
            return (o == null || o == DBNull.Value) ? null : o.ToString();
        }
    }
}