using System;
using System.Data;

namespace PrepReady.Helpers
{
    /// <summary>
    /// Tier 3 community-deployment workflow: application, officer accept/decline,
    /// session logging + sign-off, hours accrual, and badge/registry issuance.
    /// </summary>
    public static class DeploymentService
    {
        // "One month of verified service" modelled as accrued sign-off hours.
        public const decimal RequiredServiceHours = 20m;

        // ---------- Application (member side) ----------
        public static DataRow GetActiveDeploymentForCourse(int userId, int courseId)
        {
            return DBHelper.ExecuteSingleRow(
                "SELECT * FROM Deployments WHERE UserId=@U AND CourseId=@C AND Status IN ('Pending','Accepted')",
                DBHelper.Param("@U", userId), DBHelper.Param("@C", courseId));
        }

        public static string Apply(int userId, int courseId)
        {
            if (GetActiveDeploymentForCourse(userId, courseId) != null) return null; // already applied

            DataRow course = CourseService.GetCourse(courseId);
            if (course == null) return null;

            string code = "DEP-" + Guid.NewGuid().ToString("N").Substring(0, 8).ToUpper();
            string field = Convert.ToString(course["Title"]);
            string agency = Convert.ToString(course["GovPartner"]);

            DBHelper.ExecuteNonQuery(
                "INSERT INTO Deployments (UserId, CourseId, DeploymentCode, RecognisedField, EndorsingAgency, Status) " +
                "VALUES (@U, @C, @Code, @F, @A, 'Pending')",
                DBHelper.Param("@U", userId), DBHelper.Param("@C", courseId),
                DBHelper.Param("@Code", code), DBHelper.Param("@F", field), DBHelper.Param("@A", agency));

            // Notify all active officers.
            DataTable officers = DBHelper.ExecuteDataTable("SELECT Email FROM Officers WHERE IsActive=1");
            foreach (DataRow o in officers.Rows)
            {
                EmailHelper.Send(Convert.ToString(o["Email"]), "New deployment application",
                    "<p>A learner has applied for community deployment.</p>" +
                    "<p>Field: " + field + "<br/>Deployment Code: " + code + "</p>" +
                    "<p>Review it in the Officer Portal.</p>");
            }
            return code;
        }

        public static DataTable GetUserDeployments(int userId)
        {
            return DBHelper.ExecuteDataTable(
                "SELECT d.DeploymentId, d.DeploymentCode, d.CourseId, d.RecognisedField, d.EndorsingAgency, " +
                "       d.Status, d.AppliedDate, d.BadgeIssued, " +
                "  (SELECT ISNULL(SUM(cw.DurationHours),0) FROM CommunityWork cw " +
                "   WHERE cw.DeploymentCode=d.DeploymentCode AND cw.IsSignedOff=1) AS AccruedHours " +
                "FROM Deployments d WHERE d.UserId=@U ORDER BY d.AppliedDate DESC",
                DBHelper.Param("@U", userId));
        }

        public static DataTable GetEligibleCertificates(int userId)
        {
            // Tier 2+ valid certs with no active/completed deployment yet.
            return DBHelper.ExecuteDataTable(
                "SELECT c.CourseId, co.Title AS CourseTitle, co.GovPartner " +
                "FROM Certificates c INNER JOIN Courses co ON co.CourseId=c.CourseId " +
                "WHERE c.UserId=@U AND c.Tier>=2 AND c.ExpiryDate>GETDATE() " +
                "AND NOT EXISTS (SELECT 1 FROM Deployments d WHERE d.UserId=@U AND d.CourseId=c.CourseId " +
                "                AND d.Status IN ('Pending','Accepted','Completed'))",
                DBHelper.Param("@U", userId));
        }

        // ---------- Officer side ----------
        public static DataRow GetDeployment(int deploymentId)
        {
            return DBHelper.ExecuteSingleRow(
                "SELECT * FROM Deployments WHERE DeploymentId=@D", DBHelper.Param("@D", deploymentId));
        }

        public static DataTable GetPending()
        {
            return DBHelper.ExecuteDataTable(
                "SELECT d.DeploymentId, d.DeploymentCode, d.RecognisedField, d.EndorsingAgency, d.AppliedDate, u.FullName " +
                "FROM Deployments d INNER JOIN Users u ON u.UserId=d.UserId " +
                "WHERE d.Status='Pending' ORDER BY d.AppliedDate");
        }

        public static DataTable GetOfficerActive(int officerId)
        {
            return DBHelper.ExecuteDataTable(
                "SELECT d.DeploymentId, d.DeploymentCode, d.RecognisedField, d.EndorsingAgency, d.UserId, u.FullName, " +
                "  (SELECT ISNULL(SUM(cw.DurationHours),0) FROM CommunityWork cw " +
                "   WHERE cw.DeploymentCode=d.DeploymentCode AND cw.IsSignedOff=1) AS AccruedHours " +
                "FROM Deployments d INNER JOIN Users u ON u.UserId=d.UserId " +
                "WHERE d.Status='Accepted' AND d.OfficerId=@O ORDER BY d.AppliedDate",
                DBHelper.Param("@O", officerId));
        }

        public static void Accept(int deploymentId, int officerId)
        {
            DBHelper.ExecuteNonQuery(
                "UPDATE Deployments SET OfficerId=@O, Status='Accepted' WHERE DeploymentId=@D AND Status='Pending'",
                DBHelper.Param("@O", officerId), DBHelper.Param("@D", deploymentId));

            NotifyLearner(deploymentId, "Your deployment was accepted",
                "<p>An officer has accepted your community deployment. Service sessions will now be logged and signed off.</p>");
        }

        public static void Decline(int deploymentId, int officerId)
        {
            DBHelper.ExecuteNonQuery(
                "UPDATE Deployments SET OfficerId=@O, Status='Declined' WHERE DeploymentId=@D AND Status='Pending'",
                DBHelper.Param("@O", officerId), DBHelper.Param("@D", deploymentId));
        }

        public static void LogSession(string deploymentCode, int userId, int officerId,
                                      DateTime serviceDate, decimal hours, string note)
        {
            DBHelper.ExecuteNonQuery(
                "INSERT INTO CommunityWork (UserId, OfficerId, DeploymentCode, ServiceDate, DurationHours, ActivityNote, IsSignedOff, SignedOffDate) " +
                "VALUES (@U, @O, @Code, @D, @H, @N, 1, GETDATE())",
                DBHelper.Param("@U", userId), DBHelper.Param("@O", officerId),
                DBHelper.Param("@Code", deploymentCode), DBHelper.Param("@D", serviceDate),
                DBHelper.Param("@H", hours), DBHelper.Param("@N", note));
        }

        public static DataTable GetSessions(string deploymentCode)
        {
            return DBHelper.ExecuteDataTable(
                "SELECT ServiceDate, DurationHours, ActivityNote, SignedOffDate " +
                "FROM CommunityWork WHERE DeploymentCode=@Code ORDER BY ServiceDate",
                DBHelper.Param("@Code", deploymentCode));
        }

        public static decimal GetAccruedHours(string deploymentCode)
        {
            object o = DBHelper.ExecuteScalar(
                "SELECT ISNULL(SUM(DurationHours),0) FROM CommunityWork WHERE DeploymentCode=@Code AND IsSignedOff=1",
                DBHelper.Param("@Code", deploymentCode));
            return o == null ? 0m : Convert.ToDecimal(o);
        }

        /// <summary>Final verification: issues Tier 3 badge, publishes Registry, awards 500 pts.</summary>
        public static bool IssueBadge(int deploymentId, string verifyBaseUrl)
        {
            DataRow dep = GetDeployment(deploymentId);
            if (dep == null || Convert.ToBoolean(dep["BadgeIssued"])) return false;

            int userId = Convert.ToInt32(dep["UserId"]);
            int courseId = Convert.ToInt32(dep["CourseId"]);
            string code = Convert.ToString(dep["DeploymentCode"]);
            string field = Convert.ToString(dep["RecognisedField"]);
            string agency = Convert.ToString(dep["EndorsingAgency"]);

            if (GetAccruedHours(code) < RequiredServiceHours) return false;

            DataRow cert = CertificateService.GetCertificate(userId, courseId);
            if (cert == null) return false;
            int certId = Convert.ToInt32(cert["CertificateId"]);
            DateTime expiry = Convert.ToDateTime(cert["ExpiryDate"]);
            string certCode = Convert.ToString(cert["CertCode"]);

            // 1) Badge (expires with the certificate).
            int badgeId = Convert.ToInt32(DBHelper.ExecuteScalar(
                "INSERT INTO Badges (CertificateId, EndorsingAgency, IssueDate, ExpiryDate) " +
                "VALUES (@Cert, @A, GETDATE(), @E); SELECT CAST(SCOPE_IDENTITY() AS INT);",
                DBHelper.Param("@Cert", certId), DBHelper.Param("@A", agency), DBHelper.Param("@E", expiry)));

            // 2) Upgrade the certificate to Tier 3.
            DBHelper.ExecuteNonQuery("UPDATE Certificates SET Tier=3 WHERE CertificateId=@Cert",
                DBHelper.Param("@Cert", certId));

            // 3) Publish to the public Registry.
            DBHelper.ExecuteNonQuery(
                "INSERT INTO Registry (UserId, BadgeId, RecognisedField, IssueDate, ExpiryDate, EndorsingAgency, QrData) " +
                "VALUES (@U, @B, @F, GETDATE(), @E, @A, @Q)",
                DBHelper.Param("@U", userId), DBHelper.Param("@B", badgeId),
                DBHelper.Param("@F", field), DBHelper.Param("@E", expiry),
                DBHelper.Param("@A", agency), DBHelper.Param("@Q", verifyBaseUrl + certCode));

            // 4) 500-point bonus.
            PointsService.Award(userId, 500, "Government-recognised badge awarded");

            // 5) Close the deployment.
            DBHelper.ExecuteNonQuery(
                "UPDATE Deployments SET Status='Completed', BadgeIssued=1 WHERE DeploymentId=@D",
                DBHelper.Param("@D", deploymentId));

            NotifyLearner(deploymentId, "Your government-recognised badge has been awarded!",
                "<p>Congratulations! You have completed verified community service and earned your Tier 3 " +
                "Government-Recognised Badge. You are now listed in the National Recognised Responders Registry.</p>");

            // EX-4: notify the member
            NotificationService.Notify(userId,
                "Tier 3 badge awarded",
                "Congratulations! You are now recognised as a " + field + " responder and published to the National Registry.",
                "~/Member/Badges.aspx");
            return true;
        }

        private static void NotifyLearner(int deploymentId, string subject, string body)
        {
            DataRow dep = GetDeployment(deploymentId);
            if (dep == null) return;
            object email = DBHelper.ExecuteScalar("SELECT Email FROM Users WHERE UserId=@U",
                DBHelper.Param("@U", Convert.ToInt32(dep["UserId"])));
            if (email != null) EmailHelper.Send(Convert.ToString(email), subject, body);
        }
    }
}