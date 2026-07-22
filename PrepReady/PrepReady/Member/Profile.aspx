<%@ Page Title="My Profile" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Profile.aspx.cs" Inherits="PrepReady.Member.Profile" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <section class="pr-section">
        <div class="container">

            <div class="pr-section-title mb-4">
                <h1 class="h3 mb-0" style="font-family: var(--font-head);">My profile</h1>
            </div>

            <div class="row g-4">
                <!-- ===== edit form ===== -->
                <div class="col-lg-8">
                    <div class="card border-0 shadow-sm">
                        <div class="card-body p-4 p-md-5">

                            <asp:Label ID="lblMsg" runat="server" Visible="false" />

                            <div class="d-flex align-items-center gap-3 mb-4 flex-wrap">
                                <asp:Image ID="imgAvatar" runat="server" CssClass="pr-avatar-lg" Visible="false" AlternateText="Your profile photo"
                                    Style="width: 96px; height: 96px; border-radius: 50%; object-fit: cover;" />
                                <asp:Panel ID="pnlNoAvatar" runat="server" CssClass="pr-avatar-lg pr-avatar-fallback" Visible="false"
                                    Style="width: 96px; height: 96px; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center;">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                                </asp:Panel>
                                <div class="flex-grow-1" style="min-width: 240px;">
                                    <label class="form-label" for="<%= fuAvatar.ClientID %>">Profile photo</label>
                                    <asp:FileUpload ID="fuAvatar" runat="server" CssClass="form-control" accept="image/png, image/jpeg, image/gif" />
                                    <div class="form-text">JPG, PNG or GIF &middot; max 2&nbsp;MB.</div>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label" for="<%= txtFullName.ClientID %>">Full name</label>
                                <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" MaxLength="150" />
                                <asp:RequiredFieldValidator ID="rfvName" runat="server" ControlToValidate="txtFullName"
                                    ValidationGroup="pf" Display="Dynamic" CssClass="text-danger small d-block mt-1"
                                    ErrorMessage="Full name is required." />
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Email</label>
                                <div class="form-control bg-light" style="cursor: not-allowed;">
                                    <asp:Literal ID="litEmail" runat="server" /></div>
                                <div class="form-text">Your email is your sign-in ID and can't be changed here.</div>
                            </div>

                            <div class="mb-4">
                                <label class="form-label" for="<%= txtBio.ClientID %>">Bio <span class="text-muted">(optional)</span></label>
                                <asp:TextBox ID="txtBio" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="4" MaxLength="500" />
                                <div class="form-text">A short line about you (max 500 characters).</div>
                            </div>

                            <div class="d-flex gap-2 flex-wrap">
                                <asp:Button ID="btnSave" runat="server" CssClass="btn pr-btn-accent" Text="Save changes"
                                    ValidationGroup="pf" OnClick="btnSave_Click" />
                                <a href="<%= ResolveUrl("~/Account/ChangePassword.aspx") %>" class="btn pr-btn-outline">Change password</a>
                            </div>

                        </div>
                    </div>
                </div>

                <!-- ===== account summary ===== -->
                <div class="col-lg-4">
                    <div class="card border-0 shadow-sm">
                        <div class="card-body p-4">
                            <h2 class="h6 text-uppercase text-muted mb-3">Account</h2>
                            <dl class="mb-0">
                                <dt class="small text-muted">Role</dt>
                                <dd class="mb-3"><span class="pr-tag">
                                    <asp:Literal ID="litRole" runat="server" /></span></dd>
                                <dt class="small text-muted">Points balance</dt>
                                <dd class="mb-3"><span class="pr-stat-num" style="font-size: 1.6rem;">
                                    <asp:Literal ID="litPoints" runat="server" /></span></dd>
                                <dt class="small text-muted">Member since</dt>
                                <dd class="mb-0">
                                    <asp:Literal ID="litMemberSince" runat="server" /></dd>
                            </dl>
                        </div>
                    </div>
                </div>
            </div>

        </div>
    </section>
</asp:Content>
