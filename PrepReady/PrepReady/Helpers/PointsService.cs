using System;

namespace PrepReady.Helpers
{
    /// <summary>
    /// Central points engine: writes a PointTransactions ledger row and keeps
    /// Users.PointBalance in sync. Phase 7 adds the ledger/leaderboard UI on top.
    /// </summary>
    public static class PointsService
    {
        public static void Award(int userId, int points, string reason)
        {
            DBHelper.ExecuteNonQuery(
                "INSERT INTO PointTransactions (UserId, Points, Reason) VALUES (@U, @P, @R)",
                DBHelper.Param("@U", userId),
                DBHelper.Param("@P", points),
                DBHelper.Param("@R", reason));

            DBHelper.ExecuteNonQuery(
                "UPDATE Users SET PointBalance = PointBalance + @P WHERE UserId = @U",
                DBHelper.Param("@U", userId),
                DBHelper.Param("@P", points));
        }

        /// <summary>EX-15: all point transactions for a user, newest first (for the data export PDF).</summary>
        public static System.Data.DataTable GetTransactions(int userId)
        {
            return DBHelper.ExecuteDataTable(
                "SELECT Points, Reason, TxnDate FROM PointTransactions WHERE UserId = @U ORDER BY TxnDate DESC",
                DBHelper.Param("@U", userId));
        }
    }
}