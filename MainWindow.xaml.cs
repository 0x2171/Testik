using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using EasyCaptcha.Wpf;

namespace WpfApp1
{
    public partial class MainWindow : Window
    {
        public static User CurrentUser;
        public MainWindow()
        {
            InitializeComponent();
            GenerateCapcha();
        }

        private void GenerateCapcha()
        {
            Capcha.CreateCaptcha(Captcha.LetterOption.Number, 1);
        }

        private void LoginButton_Click(object sender, RoutedEventArgs e)
        {
            string login = Login.Text.Trim();
            string password = Password.Text;

            if (CapchaInput.Text != Capcha.CaptchaText)
            {
                MessageBox.Show("Неверная капча", "Ошибка", MessageBoxButton.OKCancel, MessageBoxImage.Error);
            }

            try
            {
                var parameters = new Dictionary<string, object>
                {
                    { "@login", login },
                    { "@password", password }
                };

                string query = @"SELECT u.id, u.login, u.password, u.full_name, u.role 
                                FROM users u 
                                WHERE u.login = @login AND u.password = @password";

                DataTable dt = DataBaseHelper.Execute(query, parameters);

                if (dt.Rows.Count > 0)
                {
                    var row = dt.Rows[0];
                    CurrentUser = new User
                    {
                        Id = Convert.ToInt32(row["id"]),
                        Login = row["login"].ToString(),
                        Password = row["password"].ToString(),
                        FullName = row["full_name"].ToString(),         
                    };

                    string userType = row["role"].ToString();
                    switch (userType)
                    {
                        case "User":
                            CurrentUser.Type = UserType.User;
                            break;
                    }

                    var mainWindow = new Main();
                    mainWindow.Show();
                    Close();
                }
                else
                {
                    MessageBox.Show($"Неверный логин или пароль", "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
                    GenerateCapcha();
                }
            }
            catch
            {

            }
        }

        private void ReGenerateCapcha(object sender, RoutedEventArgs e)
        {
            GenerateCapcha();
        }
    }
}
