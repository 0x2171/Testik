using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WpfApp1
{
    internal class DataBaseHelper
    {
        public static readonly string ConnectionString = "Server=localhost;Database=test_db;Uid=root;Pwd=123456789;";

        private static MySqlConnection GetConnection()
        {
            return new MySqlConnection (ConnectionString);
        }

        public static DataTable Execute(string query, Dictionary<string, object> parameters = null)
        {
           
            using(var connection = GetConnection())
            {
                connection.Open();
                using(var cmd = new MySqlCommand(query, connection))
                {
                    if (parameters != null)
                    {
                        foreach (var param in parameters)
                        {
                            cmd.Parameters.AddWithValue(param.Key, param.Value);
                        }
                    }
                    var adapter = new MySqlDataAdapter(cmd);
                    var dt = new DataTable();
                    adapter.Fill(dt);
                    return dt;
                }
            }
        }


    }
}
