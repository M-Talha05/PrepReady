<%@ Page Title="DB Test" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DbTest.aspx.cs" Inherits="PrepReady.DbTest" %>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <section class="container py-5">
        <h1 class="pr-section-title">Database Connectivity Test</h1>
        <p class="text-muted">Temporary page — confirms the app reads <code>PrepReadyDB.mdf</code> via DBHelper. Delete after Phase 2.</p>

        <asp:Label ID="lblStatus" runat="server" CssClass="d-block mb-3 fw-bold" />

        <h2 class="h5 mt-4">Seeded Courses</h2>
        <asp:GridView ID="gvCourses" runat="server" CssClass="table table-striped table-bordered"
                      AutoGenerateColumns="true" GridLines="None" />
    </section>
</asp:Content>