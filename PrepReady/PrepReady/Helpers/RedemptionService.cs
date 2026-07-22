using System;
using System.Data;
using PrepReady.Helpers;

namespace PrepReady.Helpers
{
    /// <summary>
    /// Points-redemption engine: partner catalogue, voucher generation, and the
    /// spend transaction. Spending goes through PointsService (negative ledger row)
    /// so PointBalance and the PointTransactions ledger always stay in sync.
    /// </summary>
    public static class RedemptionService
    {
        public static DataTable GetActivePartners()
        {
            return DBHelper.ExecuteDataTable(
                "SELECT PartnerId, Name, PartnerType, VoucherTitle, PointCost " +
                "FROM RedemptionPartners WHERE IsActive = 1 ORDER BY PointCost");
        }

        public static DataRow GetPartner(int partnerId)
        {
            return DBHelper.ExecuteSingleRow(
                "SELECT PartnerId, Name, VoucherTitle, PointCost, IsActive " +
                "FROM RedemptionPartners WHERE PartnerId = @P",
                DBHelper.Param("@P", partnerId));
        }

        // Voucher code style mirrors CertCode / DeploymentCode: VCH-<8 hex>.
        public static string GenerateVoucherCode()
        {
            return "VCH-" + Guid.NewGuid().ToString("N").Substring(0, 8).ToUpperInvariant();
        }

        /// <summary>
        /// Redeems a voucher. Returns the generated voucher code on success, or null
        /// if the partner is missing/inactive or the member can't afford it.
        /// </summary>
        public static string Redeem(int userId, int partnerId)
        {
            DataRow p = GetPartner(partnerId);
            if (p == null || !Convert.ToBoolean(p["IsActive"])) return null;

            int cost = Convert.ToInt32(p["PointCost"]);

            object balObj = DBHelper.ExecuteScalar(
                "SELECT PointBalance FROM Users WHERE UserId = @U",
                DBHelper.Param("@U", userId));
            int balance = (balObj == null || balObj == DBNull.Value) ? 0 : Convert.ToInt32(balObj);

            if (balance < cost) return null;   // not enough points

            string code = GenerateVoucherCode();

            // Deduct points via the ledger (negative transaction).
            PointsService.Award(userId, -cost, "Redeemed: " + Convert.ToString(p["VoucherTitle"]));

            // Record the redemption + voucher.
            DBHelper.ExecuteNonQuery(
                "INSERT INTO Redemptions (UserId, PartnerId, PointsSpent, VoucherCode) " +
                "VALUES (@U, @P, @S, @V)",
                DBHelper.Param("@U", userId),
                DBHelper.Param("@P", partnerId),
                DBHelper.Param("@S", cost),
                DBHelper.Param("@V", code));
            // EX-4: notify the member
            NotificationService.Notify(userId,
                "Voucher redeemed",
                "Your voucher " + code + " (" + Convert.ToString(p["VoucherTitle"]) + ") is ready. " + cost + " points spent.",
                "~/Member/Rewards.aspx");

            return code;
        }

        public static DataTable GetUserRedemptions(int userId)
        {
            return DBHelper.ExecuteDataTable(
                "SELECT rp.Name, rp.VoucherTitle, rd.PointsSpent, rd.VoucherCode, rd.RedeemedDate " +
                "FROM Redemptions rd " +
                "INNER JOIN RedemptionPartners rp ON rp.PartnerId = rd.PartnerId " +
                "WHERE rd.UserId = @U ORDER BY rd.RedeemedDate DESC",
                DBHelper.Param("@U", userId));
        }
    }
}