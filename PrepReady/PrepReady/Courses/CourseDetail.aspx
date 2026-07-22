<%@ Page Title="Course" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CourseDetail.aspx.cs" Inherits="PrepReady.Courses.CourseDetail" %>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <section class="pr-section">
        <div class="container">
            <a href="Catalogue.aspx" class="text-decoration-none">&larr; Back to catalogue</a>

            <div class="row mt-3 g-4">
                <div class="col-lg-8">
                    <span class="pr-tag pr-tag-red mb-2"><asp:Literal ID="litCategory" runat="server" /></span>
                    <h1 class="pr-section-title"><asp:Literal ID="litTitle" runat="server" /></h1>
                    <p class="pr-lead"><asp:Literal ID="litDesc" runat="server" /></p>

                    <div class="pr-partner d-inline-flex my-2">
                        <span class="pr-partner-seal">GOV</span>
                        Endorsed by <asp:Literal ID="litPartner" runat="server" />
                    </div>

                    <h2 class="h5 mt-4 mb-3">Lessons</h2>
                    <ol class="list-group list-group-numbered pr-lesson-list">
                        <asp:Repeater ID="rptLessons" runat="server" OnItemDataBound="rptLessons_ItemDataBound">
                            <ItemTemplate>
                                <li class="list-group-item d-flex justify-content-between align-items-center">
                                    <span><%# Server.HtmlEncode(Convert.ToString(Eval("Title"))) %></span>
                                    <asp:Literal ID="litLessonStatus" runat="server" />
                                </li>
                            </ItemTemplate>
                        </asp:Repeater>
                    </ol>

                    <!-- ===== EX-5: course reviews ===== -->
                    <section class="mt-5" aria-labelledby="revHead">
                        <h2 id="revHead" class="h5 mb-2">Ratings &amp; reviews</h2>
                        <p class="pr-avg-rating mb-4"><asp:Literal ID="litAvgStars" runat="server" /></p>

                        <asp:Label ID="lblReviewHint" runat="server" Visible="false" CssClass="text-muted small d-block mb-3"
                                   Text="Complete this course (earn its certificate) to leave a review." />

                        <asp:Panel ID="pnlReviewForm" runat="server" Visible="false" CssClass="card mb-4">
                            <div class="card-body">
                                <h3 class="h6 mb-3">Leave your review</h3>
                                <asp:Label ID="lblReviewMsg" runat="server" Visible="false" />
                                <div class="mb-3" style="max-width:240px;">
                                    <label class="form-label" for="<%= ddlRating.ClientID %>">Your rating</label>
                                    <asp:DropDownList ID="ddlRating" runat="server" CssClass="form-select">
                                        <asp:ListItem Value="5">★★★★★ — Excellent</asp:ListItem>
                                        <asp:ListItem Value="4">★★★★ — Good</asp:ListItem>
                                        <asp:ListItem Value="3">★★★ — Average</asp:ListItem>
                                        <asp:ListItem Value="2">★★ — Poor</asp:ListItem>
                                        <asp:ListItem Value="1">★ — Terrible</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label" for="<%= txtComment.ClientID %>">Your comment <span class="text-muted">(optional)</span></label>
                                    <asp:TextBox ID="txtComment" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" MaxLength="1000" />
                                </div>
                                <asp:Button ID="btnReview" runat="server" CssClass="btn pr-btn-accent" Text="Submit review" OnClick="btnReview_Click" />
                            </div>
                        </asp:Panel>

                        <asp:Label ID="lblNoReviews" runat="server" CssClass="text-muted" Visible="false"
                                   Text="No reviews yet — be the first to review this course." />

                        <asp:Repeater ID="rptReviews" runat="server">
                            <ItemTemplate>
                                <div class="pr-review-item">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <strong><%# Server.HtmlEncode(Eval("FullName").ToString()) %></strong>
                                        <small class="text-muted"><%# Convert.ToDateTime(Eval("CreatedDate")).ToString("dd MMM yyyy") %></small>
                                    </div>
                                    <div class="pr-stars"><%# new string('\u2605', Convert.ToInt32(Eval("Rating"))) + new string('\u2606', 5 - Convert.ToInt32(Eval("Rating"))) %></div>
                                    <p class="mb-0 text-muted"><%# Server.HtmlEncode(Convert.ToString(Eval("Comment"))) %></p>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </section>
                </div>

                <div class="col-lg-4">
                    <div class="card pr-sticky-lg">
                        <div class="card-body">
                            <h2 class="h6 text-uppercase text-muted">Your progress</h2>

                            <asp:Panel ID="pnlProgress" runat="server" Visible="false">
                                <div class="progress my-2" role="progressbar">
                                    <div id="bar" runat="server" class="progress-bar" style="background:#0b1f3a;">
                                        <asp:Literal ID="litPercent" runat="server" />%
                                    </div>
                                </div>
                                <p class="small text-muted mb-3"><asp:Literal ID="litProgressText" runat="server" /></p>
                                <asp:HyperLink ID="lnkContinue" runat="server" CssClass="pr-btn-accent w-100 text-center d-block" />
                            </asp:Panel>

                            <asp:Panel ID="pnlEnroll" runat="server">
                                <p class="text-muted small">Enroll to start the lessons and track progress.</p>
                                <asp:Button ID="btnEnroll" runat="server" CssClass="pr-btn-accent w-100"
                                            Text="Enroll now" OnClick="btnEnroll_Click" />
                            </asp:Panel>

                            <%-- Final exam panel (enrolled members only) --%>
                            <asp:Panel ID="pnlExam" runat="server" Visible="false" CssClass="mt-3 pt-3 border-top">
                                <h2 class="h6 text-uppercase text-muted">Final exam</h2>
                                <asp:Literal ID="litExamMsg" runat="server" />
                                <asp:HyperLink ID="lnkExam" runat="server" Visible="false"
                                               CssClass="pr-btn-accent w-100 text-center d-block mt-2" />
                            </asp:Panel>

                            <%-- EX-9: save / bookmark (members only) --%>
                            <asp:Panel ID="pnlBookmark" runat="server" Visible="false" CssClass="mt-3 pt-3 border-top">
                                <asp:Button ID="btnBookmark" runat="server" CausesValidation="false"
                                            CssClass="btn pr-btn-outline w-100" OnClick="btnBookmark_Click" />
                                <p class="small text-muted mt-2 mb-0">
                                    Saved courses appear in
                                    <a href='<%= ResolveUrl("~/Member/MyLearning.aspx") %>'>My Learning</a>.
                                </p>
                            </asp:Panel>

                            <asp:Label ID="lblNote" runat="server" CssClass="alert alert-info d-block mt-3" Visible="false" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
</asp:Content>