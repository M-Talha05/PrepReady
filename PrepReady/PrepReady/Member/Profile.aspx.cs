using System;
using System.Data;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;
using PrepReady.Helpers;

namespace PrepReady.Member
{
    public partial class Profile : BasePage
    {
        // Users-table accounts (Members + Admins) have profiles/avatars.
        protected override string[] AllowedRoles
        {
            get { return new[] { "Member", "Admin" }; }
        }

        private static readonly string[] AllowedExt = { ".jpg", ".jpeg", ".png", ".gif" };
        private const int MaxBytes = 2 * 1024 * 1024; // 2 MB
        private const int AvatarSize = 256;            // stored square size in px

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadProfile();
            }
        }

        private void LoadProfile()
        {
            DataRow p = ProfileService.GetProfile(CurrentUserId);
            if (p == null) return;

            txtFullName.Text = p["FullName"].ToString();
            txtBio.Text = p["Bio"] == DBNull.Value ? "" : p["Bio"].ToString();
            LoadReadOnly(p);
        }

        private void LoadReadOnly()
        {
            DataRow p = ProfileService.GetProfile(CurrentUserId);
            if (p != null) LoadReadOnly(p);
        }

        private void LoadReadOnly(DataRow p)
        {
            litEmail.Text = Server.HtmlEncode(p["Email"].ToString());
            litRole.Text = Server.HtmlEncode(p["Role"].ToString());
            litPoints.Text = p["PointBalance"].ToString();
            litMemberSince.Text = Convert.ToDateTime(p["RegistrationDate"]).ToString("d MMM yyyy");

            string avatar = p["AvatarPath"] == DBNull.Value ? "" : p["AvatarPath"].ToString();
            ShowAvatar(avatar);
        }

        private void ShowAvatar(string avatarPath)
        {
            bool has = !string.IsNullOrEmpty(avatarPath);
            imgAvatar.Visible = has;
            pnlNoAvatar.Visible = !has;
            if (has) imgAvatar.ImageUrl = ResolveUrl(avatarPath);
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            // --- validate the optional avatar BEFORE writing anything ---
            string newAvatarRel = null;
            if (fuAvatar.HasFile)
            {
                string ext = Path.GetExtension(fuAvatar.FileName).ToLowerInvariant();

                if (Array.IndexOf(AllowedExt, ext) < 0)
                {
                    ShowMessage("Please upload a JPG, PNG or GIF image.", false);
                    LoadReadOnly();
                    return;
                }
                if (fuAvatar.PostedFile.ContentLength > MaxBytes)
                {
                    ShowMessage("Image must be 2 MB or smaller.", false);
                    LoadReadOnly();
                    return;
                }

                string dir = Server.MapPath("~/Content/uploads/avatars/");
                if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);

                // Always store a uniform 256x256 PNG, regardless of the source format/size.
                string fileName = "u" + CurrentUserId + "_" + Guid.NewGuid().ToString("N") + ".png";
                string fullPath = Path.Combine(dir, fileName);

                try
                {
                    SaveSquareAvatar(fuAvatar.PostedFile.InputStream, fullPath, AvatarSize);
                }
                catch
                {
                    ShowMessage("That file doesn't look like a valid image. Please try another.", false);
                    LoadReadOnly();
                    return;
                }

                newAvatarRel = "~/Content/uploads/avatars/" + fileName;
            }

            // --- save text fields (defensive length guards) ---
            string fullName = txtFullName.Text.Trim();
            if (fullName.Length > 150) fullName = fullName.Substring(0, 150);
            string bio = txtBio.Text.Trim();
            if (bio.Length > 500) bio = bio.Substring(0, 500);

            ProfileService.UpdateProfile(CurrentUserId, fullName, bio);
            Session["FullName"] = fullName; // keep navbar greeting in sync

            // --- save avatar + remove the previous file ---
            if (newAvatarRel != null)
            {
                string old = ProfileService.GetAvatarPath(CurrentUserId);
                ProfileService.UpdateAvatar(CurrentUserId, newAvatarRel);
                Session["AvatarPath"] = newAvatarRel;

                if (!string.IsNullOrEmpty(old))
                {
                    try
                    {
                        string oldPath = Server.MapPath(old);
                        if (File.Exists(oldPath)) File.Delete(oldPath);
                    }
                    catch { /* best-effort cleanup */ }
                }
            }

            ShowMessage("Your profile has been updated.", true);
            LoadProfile();
        }

        /// <summary>
        /// Reads an uploaded image, centre-crops it to a square, scales it to
        /// size x size, and writes it out as a PNG. Keeps stored avatars small
        /// and uniform.
        /// </summary>
        private static void SaveSquareAvatar(Stream input, string destPath, int size)
        {
            using (Image src = Image.FromStream(input))
            {
                int side = Math.Min(src.Width, src.Height);
                int sx = (src.Width - side) / 2;
                int sy = (src.Height - side) / 2;

                using (Bitmap bmp = new Bitmap(size, size))
                {
                    using (Graphics g = Graphics.FromImage(bmp))
                    {
                        g.InterpolationMode = InterpolationMode.HighQualityBicubic;
                        g.SmoothingMode = SmoothingMode.HighQuality;
                        g.PixelOffsetMode = PixelOffsetMode.HighQuality;

                        g.DrawImage(
                            src,
                            new Rectangle(0, 0, size, size),     // destination (full square)
                            new Rectangle(sx, sy, side, side),   // source (centre crop)
                            GraphicsUnit.Pixel);
                    }
                    bmp.Save(destPath, ImageFormat.Png);
                }
            }
        }

        private void ShowMessage(string msg, bool success)
        {
            lblMsg.Visible = true;
            lblMsg.CssClass = success ? "alert alert-success d-block" : "alert alert-danger d-block";
            lblMsg.Text = msg;
        }
    }
}