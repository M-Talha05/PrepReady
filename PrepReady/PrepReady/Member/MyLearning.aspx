<%@ Page Title="My Learning" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MyLearning.aspx.cs" Inherits="PrepReady.Member.MyLearning" %>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
  <section class="pr-section">
    <div class="container">
      <p class="pr-eyebrow mb-1">Your hub</p>
      <h1 class="pr-section-title">My Learning</h1>

      <%-- ===== Continue learning ===== --%>
      <h2 class="h5 mt-4 mb-3">Continue learning</h2>
      <asp:Label ID="lblNoProgress" runat="server" CssClass="alert alert-info d-block" Visible="false"
                 Text="You haven't enrolled in any courses yet. Browse the catalogue to get started." />
      <div class="row g-4">
        <asp:Repeater ID="rptProgress" runat="server">
          <ItemTemplate>
            <article class="col-sm-6 col-lg-4">
              <div class="pr-cat-card d-flex flex-column h-100">
                <span class="pr-tag mb-3" style="align-self:flex-start;"><%# Eval("CategoryName") %></span>
                <h3 class="pr-clamp-2"><%# Server.HtmlEncode(Eval("Title").ToString()) %></h3>
                <div class="progress pr-learn-bar my-2" role="progressbar">
                  <div class="progress-bar" style='background:#0b1f3a; width:<%# Pct(Eval("DoneLessons"), Eval("TotalLessons")) %>%;'></div>
                </div>
                <p class="small text-muted flex-grow-1">
                  <%# Eval("DoneLessons") %> of <%# Eval("TotalLessons") %> lessons
                  (<%# Pct(Eval("DoneLessons"), Eval("TotalLessons")) %>%)
                </p>
                <div class="d-flex gap-2">
                  <a class="pr-btn-accent text-center flex-grow-1" href='<%# ContinueUrl(Eval("CourseId")) %>'>Continue</a>
                  <a class="btn pr-btn-outline" href='<%# ResolveUrl("~/Courses/CourseDetail.aspx?id=" + Eval("CourseId")) %>'>Details</a>
                </div>
              </div>
            </article>
          </ItemTemplate>
        </asp:Repeater>
      </div>

      <%-- ===== Saved courses ===== --%>
      <h2 class="h5 mt-5 mb-3">Saved courses</h2>
      <asp:Label ID="lblNoSaved" runat="server" CssClass="alert alert-info d-block" Visible="false"
                 Text="No saved courses yet. Tap the heart on any course to save it for later." />
      <div class="row g-4">
        <asp:Repeater ID="rptSaved" runat="server" OnItemCommand="rptSaved_ItemCommand">
          <ItemTemplate>
            <article class="col-sm-6 col-lg-4">
              <div class="pr-cat-card d-flex flex-column h-100">
                <span class="pr-tag mb-3" style="align-self:flex-start;"><%# Eval("CategoryName") %></span>
                <h3 class="pr-clamp-2"><%# Server.HtmlEncode(Eval("Title").ToString()) %></h3>
                <p class="flex-grow-1 pr-clamp-3"><%# Server.HtmlEncode(Convert.ToString(Eval("Description"))) %></p>
                <div class="d-flex align-items-center gap-2 pr-card-meta mt-2 mb-3">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 5h16v14H4z"/><path d="M4 9h16"/></svg>
                  <span><%# Eval("LessonCount") %> lessons · <%# Eval("GovPartner") %></span>
                </div>
                <div class="d-flex gap-2">
                  <a class="pr-btn-accent text-center flex-grow-1" href='<%# ResolveUrl("~/Courses/CourseDetail.aspx?id=" + Eval("CourseId")) %>'>View course</a>
                  <asp:LinkButton runat="server" CssClass="btn btn-outline-danger" Text="Remove"
                                  CommandName="remove" CommandArgument='<%# Eval("CourseId") %>' />
                </div>
              </div>
            </article>
          </ItemTemplate>
        </asp:Repeater>
      </div>
    </div>
  </section>
</asp:Content>