using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace PrepReady.Helpers
{
    /// <summary>
    /// Central ADO.NET data-access helper for PrepReady.
    /// ALL queries are parameterized (no string concatenation into SQL) to
    /// prevent SQL injection. Connections are always wrapped in 'using' so
    /// they are disposed/closed even if an error occurs.
    /// </summary>
    public static class DBHelper
    {
        // Reads the |DataDirectory| LocalDB connection string from Web.config.
        private static string ConnectionString
        {
            get { return ConfigurationManager.ConnectionStrings["PrepReadyDB"].ConnectionString; }
        }

        /// <summary>Creates a new (unopened) SqlConnection.</summary>
        public static SqlConnection GetConnection()
        {
            return new SqlConnection(ConnectionString);
        }

        /// <summary>
        /// Convenience factory for a parameter. Converts null to DBNull so
        /// callers can pass C# null for optional columns.
        /// </summary>
        public static SqlParameter Param(string name, object value)
        {
            return new SqlParameter(name, value ?? DBNull.Value);
        }

        /// <summary>INSERT / UPDATE / DELETE — returns rows affected.</summary>
        public static int ExecuteNonQuery(string sql, params SqlParameter[] parameters)
        {
            using (SqlConnection con = GetConnection())
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                if (parameters != null && parameters.Length > 0)
                    cmd.Parameters.AddRange(parameters);

                con.Open();
                return cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Returns the first column of the first row (e.g. COUNT(*), SCOPE_IDENTITY()).
        /// Returns null if there is no result.
        /// </summary>
        public static object ExecuteScalar(string sql, params SqlParameter[] parameters)
        {
            using (SqlConnection con = GetConnection())
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                if (parameters != null && parameters.Length > 0)
                    cmd.Parameters.AddRange(parameters);

                con.Open();
                object result = cmd.ExecuteScalar();
                return (result == DBNull.Value) ? null : result;
            }
        }

        /// <summary>Runs a SELECT and returns the results as a DataTable (great for GridView binding).</summary>
        public static DataTable ExecuteDataTable(string sql, params SqlParameter[] parameters)
        {
            using (SqlConnection con = GetConnection())
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                if (parameters != null && parameters.Length > 0)
                    cmd.Parameters.AddRange(parameters);

                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt); // Fill opens and closes the connection automatically.
                    return dt;
                }
            }
        }

        /// <summary>Returns the first matching row, or null if none.</summary>
        public static DataRow ExecuteSingleRow(string sql, params SqlParameter[] parameters)
        {
            DataTable dt = ExecuteDataTable(sql, parameters);
            return dt.Rows.Count > 0 ? dt.Rows[0] : null;
        }
    }
}