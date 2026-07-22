<%@ Page Title="Assessment" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Assessment.aspx.cs" Inherits="PrepReady.Courses.Assessment" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <%-- INTERNAL CSS: quiz question + option styling --%>
    <style>
        .pr-q-num {
            flex: 0 0 auto;
            width: 30px; height: 30px;
            border-radius: 50%;
            background: var(--navy); color: #fff;
            font-family: var(--font-head); font-weight: 600; font-size: .9rem;
            display: inline-flex; align-items: center; justify-content: center;
        }
        .pr-quiz-options { line-height: 2; }
        .pr-quiz-options label {
            cursor: pointer;
            padding: .35rem .5rem;
            border-radius: var(--r-sm);
            transition: background var(--t);
        }
        .pr-quiz-options label:hover { background: #f1f5f9; }
        .pr-quiz-options input[type=radio] {
            margin-right: .6rem;
            accent-color: var(--red);
        }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <section class="pr-section">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-lg-8">
                    <a id="lnkBack" runat="server" class="text-decoration-none">&larr; Back to course</a>

                    <p class="pr-eyebrow mt-2 mb-1">Assessment</p>
                    <h1 class="pr-section-title h2"><asp:Literal ID="litHeading" runat="server" /></h1>
                    <p class="text-muted"><asp:Literal ID="litSub" runat="server" /></p>

                    <asp:Label ID="lblBlocked" runat="server" CssClass="alert alert-warning d-block" Visible="false" />

                    <asp:Panel ID="pnlQuiz" runat="server">
                        <asp:Repeater ID="rptQuestions" runat="server" OnItemDataBound="rptQuestions_ItemDataBound">
                            <ItemTemplate>
                                <div class="card mb-3">
                                    <div class="card-body">
                                        <div class="d-flex gap-3">
                                            <span class="pr-q-num" aria-hidden="true"><%# Container.ItemIndex + 1 %></span>
                                            <div class="flex-grow-1">
                                                <p class="fw-semibold mb-3">
                                                    <%# Server.HtmlEncode(Convert.ToString(Eval("Question"))) %>
                                                </p>
                                                <asp:HiddenField ID="hfQuizId" runat="server" Value='<%# Eval("QuizId") %>' />
                                                <asp:RadioButtonList ID="rblOptions" runat="server"
                                                                     RepeatLayout="Flow" RepeatDirection="Vertical"
                                                                     CssClass="pr-quiz-options" />
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>

                        <asp:Label ID="lblValidate" runat="server" CssClass="text-danger d-block mb-2"
                                   Visible="false" Text="Please answer every question before submitting." />
                        <asp:Button ID="btnSubmit" runat="server" CssClass="pr-btn-accent"
                                    Text="Submit answers" OnClick="btnSubmit_Click" />
                    </asp:Panel>

                    <asp:Panel ID="pnlResult" runat="server" Visible="false">
                        <div id="resultBox" runat="server" class="alert d-block">
                            <asp:Literal ID="litResult" runat="server" />
                        </div>
                        <asp:HyperLink ID="lnkNext" runat="server" CssClass="pr-btn-accent d-inline-block mt-2" />
                    </asp:Panel>
                </div>
            </div>
        </div>
    </section>
</asp:Content>