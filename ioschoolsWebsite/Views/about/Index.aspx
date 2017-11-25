﻿<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Main.Master" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    About 
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="nav_side mt20">
        <ul>
            <li><a class="selected" href="/about">About </a></li>
            <li><a href="/about/history">History</a></li>
            <li><a href="/about/philosophy">Philosophy</a></li>
            <li><a href="/about/vision">Vision</a></li>
            <li><a href="/about/mission">Mission</a></li>
            <li><a href="/about/people">People</a></li>
            <li><a href="/about/spirit">Spirit</a></li>
        </ul>
    </div>
    <div class="col_2 ml20 mt10">
        <div class="breadcrumb">
            <a href="/">Home</a> / About 
        </div>
        <h1>
            About </h1>
    </div>
    <script type="text/javascript">
        $(document).ready(function () {
            $('.slider').nivoSlider({
                controlNav: false,
                directionNav: false,
                pauseTime: 4000,
                pauseOnHover: false
            });
        });
    </script>
</asp:Content>