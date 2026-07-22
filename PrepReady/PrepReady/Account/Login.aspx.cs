using System;
using System.Data;
using PrepReady.Helpers;

namespace PrepReady.Account
{
    public partial class Login : System.Web.UI.Page
    {
        protected void btnLogin_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text;
            string ip = Request.UserHostAddress;

            // 1) Try the Users table (Member / Admin).
            DataRow user = AuthService.GetUserByEmail(email);
            if (user != null)
            {
                int userId = Convert.ToInt32(user["UserId"]);

                if (!Convert.ToBoolean(user["IsActive"]))
                {
                    AuditService.Log(email, userId, false, ip, "Inactive account");
                    ShowError("This account is deactivated.");
                    return;
                }

                // Lockout check BEFORE verifying the password.
                DateTime? lockedUntil = AuditService.GetActiveLockout(email);
                if (lockedUntil.HasValue)
                {
                    AuditService.Log(email, userId, false, ip, "Locked out");
                    ShowError("Too many failed attempts. This account is locked until " +
                              lockedUntil.Value.ToString("h:mm tt") +
                              ". Try again later, or reset your password.");
                    return;
                }

                if (!AuthService.VerifyPassword(password, user["PasswordHash"].ToString()))
                {
                    DateTime? nowLocked = AuditService.RegisterFailure(userId);
                    AuditService.Log(email, userId, false, ip,
                        nowLocked.HasValue ? "Bad password (now locked)" : "Bad password");

                    if (nowLocked.HasValue)
                        ShowError("Too many failed attempts. This account is now locked until " +
                                  nowLocked.Value.ToString("h:mm tt") + ".");
                    else
                        ShowError("Invalid email or password.");
                    return;
                }

                if (!Convert.ToBoolean(user["IsEmailVerified"]))
                {
                    AuditService.Log(email, userId, false, ip, "Email not verified");
                    ShowError("Please verify your email before logging in (check App_Data/EmailLog.txt for the link).");
                    return;
                }

                // Password OK — clear any failure count.
                AuditService.ResetFailures(userId);

                // EX-10: if two-factor is on, DON'T grant the session yet — send a code
                // and hand off to the OTP verification step.
                if (TwoFactorService.IsEnabled(userId))
                {
                    string code = TwoFactorService.GenerateOtp(userId);

                    Session["2fa_UserId"] = userId;
                    Session["2fa_FullName"] = user["FullName"].ToString();
                    Session["2fa_Role"] = user["Role"].ToString();
                    Session["2fa_Email"] = email;
                    Session["2fa_ReturnUrl"] = Request.QueryString["returnUrl"];
                    Session["2fa_Ip"] = ip;
                    Session["2fa_DevCode"] = Request.IsLocal ? code : null;   // shown on-screen in dev only
                    Session["2fa_Remember"] = chkRemember.Checked;             // EX-16: carry through 2FA

                    EmailHelper.Send(email, "Your PrepReady sign-in code",
                        "<p>Your one-time sign-in code is " +
                        "<strong style='font-size:1.3em; letter-spacing:2px;'>" + code + "</strong>.</p>" +
                        "<p>It expires in 5 minutes. If you didn't try to sign in, you can ignore this email.</p>");

                    AuditService.Log(email, userId, true, ip, "Password OK - OTP sent");
                    Response.Redirect("~/Account/VerifyOtp.aspx");
                    return;
                }

                // No 2FA — grant the session as usual.
                AuditService.Log(email, userId, true, ip, "Login OK");

                Session["UserId"] = userId;
                Session["FullName"] = user["FullName"].ToString();
                Session["Role"] = user["Role"].ToString();   // 'Member' or 'Admin'
                Session["Email"] = email;
                Session["AvatarPath"] = null;                 // navbar reloads the avatar

                // EX-16: issue a trusted-device token (members only).
                if (chkRemember.Checked && user["Role"].ToString() == "Member")
                    RememberService.IssueToken(userId, Response);

                RedirectAfterLogin(user["Role"].ToString());
                return;
            }

            // 2) Otherwise try the Officers table (audited; no lockout / no 2FA columns).
            DataRow officer = AuthService.GetOfficerByEmail(email);
            if (officer != null)
            {
                if (!Convert.ToBoolean(officer["IsActive"]))
                {
                    AuditService.Log(email, null, false, ip, "Inactive officer");
                    ShowError("This officer account is deactivated.");
                    return;
                }
                if (!AuthService.VerifyPassword(password, officer["PasswordHash"].ToString()))
                {
                    AuditService.Log(email, null, false, ip, "Bad password (officer)");
                    ShowError("Invalid email or password.");
                    return;
                }

                AuditService.Log(email, null, true, ip, "Officer login OK");

                Session["OfficerId"] = Convert.ToInt32(officer["OfficerId"]);
                Session["FullName"] = officer["FullName"].ToString();
                Session["Role"] = "Officer";
                Session["Email"] = email;
                Session["AvatarPath"] = null;

                RedirectAfterLogin("Officer");   // officers are excluded from remember-me
                return;
            }

            // 3) No match.
            AuditService.Log(email, null, false, ip, "Unknown email");
            ShowError("Invalid email or password.");
        }

        private void ShowError(string msg)
        {
            lblError.Text = msg;
            lblError.Visible = true;
        }

        private void RedirectAfterLogin(string role)
        {
            // Honour a safe, local returnUrl if present (prevents open-redirect attacks).
            string returnUrl = Request.QueryString["returnUrl"];
            if (!string.IsNullOrEmpty(returnUrl) && returnUrl.StartsWith("/") && !returnUrl.StartsWith("//"))
            {
                Response.Redirect(returnUrl);
                return;
            }

            if (role == "Admin")
                Response.Redirect("~/Admin/Default.aspx");
            else if (role == "Officer")
                Response.Redirect("~/Officer/Portal.aspx");
            else
                Response.Redirect("~/Member/Dashboard.aspx");
        }
    }
}