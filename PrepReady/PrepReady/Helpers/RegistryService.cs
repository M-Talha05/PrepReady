using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;

namespace PrepReady.Helpers
{
    /// <summary>
    /// Read-only access to the public National Recognised Responders Registry.
    /// Joins Registry -> Users (holder name) -> Badges -> Certificates (cert code,
    /// so each entry can link to the public Verify page).
    /// </summary>
    public static class RegistryService
    {
        // Optional name keyword + optional recognised-field filter. Both may be blank.
        public static DataTable Search(string keyword, string field)
        {
            StringBuilder sql = new StringBuilder(
                "SELECT r.RegistryId, u.FullName, r.RecognisedField, r.EndorsingAgency, " +
                "       r.IssueDate, r.ExpiryDate, c.CertCode " +
                "FROM Registry r " +
                "INNER JOIN Users u        ON u.UserId        = r.UserId " +
                "INNER JOIN Badges b       ON b.BadgeId       = r.BadgeId " +
                "INNER JOIN Certificates c ON c.CertificateId = b.CertificateId " +
                "WHERE 1 = 1 ");

            List<SqlParameter> ps = new List<SqlParameter>();

            if (!string.IsNullOrWhiteSpace(keyword))
            {
                sql.Append("AND u.FullName LIKE @kw ");
                ps.Add(DBHelper.Param("@kw", "%" + keyword.Trim() + "%"));
            }
            if (!string.IsNullOrWhiteSpace(field))
            {
                sql.Append("AND r.RecognisedField = @field ");
                ps.Add(DBHelper.Param("@field", field));
            }

            sql.Append("ORDER BY r.IssueDate DESC");
            return DBHelper.ExecuteDataTable(sql.ToString(), ps.ToArray());
        }

        // Distinct recognised fields, for the filter dropdown.
        public static DataTable GetFields()
        {
            return DBHelper.ExecuteDataTable(
                "SELECT DISTINCT RecognisedField FROM Registry ORDER BY RecognisedField");
        }
    }
}