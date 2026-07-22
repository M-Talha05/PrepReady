<%@ Page Title="My Data & Privacy" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MyData.aspx.cs" Inherits="PrepReady.Member.MyData" %>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <section class="pr-section">
        <div class="container">
            <p class="pr-eyebrow mb-1">Privacy controls</p>
            <h1 class="pr-section-title">My Data &amp; Privacy</h1>

            <div class="row g-4">
                <!-- ===== Export ===== -->
                <div class="col-lg-6">
                    <div class="card border-0 shadow-sm h-100">
                        <div class="card-body p-4">
                            <h2 class="h5">Download my data</h2>
                            <p class="text-muted small">
                                Export a PDF copy of the personal data PrepReady holds about you — your profile,
                                certificates, course enrolments, and points activity.
                            </p>
                            <a href="<%: ResolveUrl("~/Member/DataExportPdf.aspx") %>" target="_blank"
                               class="btn pr-btn-accent">Download my data (PDF)</a>
                        </div>
                    </div>
                </div>

                <!-- ===== Danger zone ===== -->
                <div class="col-lg-6">
                    <div class="card border-0 shadow-sm h-100" style="border-top: 4px solid var(--red) !important;">
                        <div class="card-body p-4">
                            <h2 class="h5 text-danger">Delete my account</h2>
                            <p class="text-muted small mb-3">
                                This permanently deletes your account and all associated data — certificates,
                                points, enrolments, bookmarks, reviews, and messages.
                                <strong>This cannot be undone.</strong>
                            </p>

                            <asp:Label ID="lblDelError" runat="server" CssClass="alert alert-danger d-block" Visible="false" />

                            <div class="mb-3">
                                <label class="form-label" for="<%= txtPassword.ClientID %>">Confirm your password</label>
                                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="form-control" />
                                <asp:RequiredFieldValidator ID="rfvPwd" runat="server" ControlToValidate="txtPassword"
                                    ValidationGroup="del" Display="Dynamic" CssClass="text-danger small"
                                    ErrorMessage="Enter your password to confirm." />
                            </div>

                            <div class="form-check mb-3">
                                <asp:CheckBox ID="chkConfirm" runat="server" CssClass="form-check-input" />
                                <label class="form-check-label small" for="<%= chkConfirm.ClientID %>">
                                    I understand this is permanent and cannot be undone.
                                </label>
                            </div>

                            <asp:Button ID="btnDelete" runat="server" CssClass="btn btn-danger"
                                Text="Permanently delete my account" ValidationGroup="del"
                                OnClick="btnDelete_Click"
                                OnClientClick="if(!confirm('Delete your PrepReady account permanently? This cannot be undone.')){return false;}" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
</asp:Content>