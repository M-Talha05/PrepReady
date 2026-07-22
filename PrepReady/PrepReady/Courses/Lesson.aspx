<%@ Page Title="Lesson" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Lesson.aspx.cs" Inherits="PrepReady.Courses.Lesson" %>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <section class="pr-section">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-lg-9">
                    <a id="lnkBack" runat="server" class="text-decoration-none">&larr; Back to course</a>

                    <div class="progress my-3" role="progressbar" style="height:10px;">
                        <div id="bar" runat="server" class="progress-bar" style="background:#0b1f3a;"></div>
                    </div>
                    <p class="small text-muted"><asp:Literal ID="litProgressText" runat="server" /></p>

                    <article class="card pr-lesson-card">
                        <div class="card-body p-4 p-md-5">
                            <h1 class="pr-section-title h2 mb-3"><asp:Literal ID="litTitle" runat="server" /></h1>

                            <asp:Literal ID="litMedia" runat="server" />

                            <div class="pr-lesson-body">
                                <asp:Literal ID="litBody" runat="server" />
                            </div>

                            <asp:Label ID="lblDone" runat="server" CssClass="alert alert-success d-block mt-4"
                                       Visible="false" Text="You have completed this lesson." />

                            <%-- Lesson quiz CTA --%>
                            <asp:Panel ID="pnlQuiz" runat="server" Visible="false" CssClass="pr-quiz-cta mt-4">
                                <h2 class="h6 mb-2">Lesson quiz</h2>
                                <p class="small text-muted mb-2"><asp:Literal ID="litQuizMsg" runat="server" /></p>
                                <asp:HyperLink ID="lnkQuiz" runat="server" CssClass="pr-btn-outline" />
                            </asp:Panel>
                        </div>
                    </article>

                    <div class="d-flex justify-content-between mt-4">
                        <asp:HyperLink ID="lnkPrev" runat="server" CssClass="pr-btn-outline" Text="&larr; Previous" />
                        <asp:Button ID="btnComplete" runat="server" CssClass="pr-btn-accent"
                                    Text="Mark complete &amp; continue" OnClick="btnComplete_Click" />
                    </div>
                </div>
            </div>
        </div>
    </section>
</asp:Content>