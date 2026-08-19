<%@ Page Language="C#" AutoEventWireup="true" Inherits="Rock.Web.UI.RockPage" %>

<!DOCTYPE html>

<html>
<head runat="server">
    <meta charset="utf-8">
    <title></title>
    
    <!-- Set the viewport width to device width for mobile -->
	<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">

    <script src="<%# System.Web.Optimization.Scripts.Url("~/Scripts/Bundles/RockJQueryLatest" ) %>"></script>

    <link rel="stylesheet" href="<%# ResolveRockUrl("~~/Styles/bootstrap.css", true) %>" />
    <link rel="stylesheet" href="<%# ResolveRockUrl("~~/Styles/theme.css", true) %>" />

    <style>
        html, body {
            height: auto;
            width: 100%;
            min-width: 100%;
            background-color: #ffffff;
            margin: 0;
            padding: 0;
            vertical-align: top;
        }
        *, *::before, *::after {
            box-sizing: border-box;
        }
    </style>

</head>

<body class="login-page rock-blank">
    <form id="form1" runat="server">
        <asp:ScriptManager ID="sManager" runat="server" />

        <asp:UpdateProgress ID="updateProgress" runat="server" DisplayAfter="800">
            <ProgressTemplate>
                <div class="updateprogress-status">
                    <div class="spinner">
                        <div class="rect1"></div>
                        <div class="rect2"></div>
                        <div class="rect3"></div>
                        <div class="rect4"></div>
                        <div class="rect5"></div>
                    </div>
                </div>
                <div class="updateprogress-bg modal-backdrop">
                </div>
            </ProgressTemplate>
        </asp:UpdateProgress>

        <!-- Start Content Area -->
        <main>

            <!-- Ajax Error -->
            <div class="alert alert-danger ajax-error no-index" style="display:none">
                <p><strong>Error</strong></p>
                <span class="ajax-error-message"></span>
            </div>

            <!-- Start Zones -->    
            <div class="login-page-grid">

                <div class="col-1" id="col-1">
                
                    <div id="nav-content" class="login-page-nav">
                        <Rock:Zone Name="Nav" runat="server" />
                    </div>

                    <div id="main-content" class="login-page-main">
                        <Rock:Zone Name="Main" runat="server" />
                    </div>
                    
                    <div id="footer-content" class="login-page-footer">
                        <Rock:Zone Name="Main-Footer" runat="server" />
                    </div>

                </div>

                <div class="col-2" id="col-2">
                    <div class="login-page-feature" id="feature">
                        <Rock:Zone Name="Feature" runat="server" />
                    </div>
                </div>

            </div>
            <!-- End Zones -->

        </main>
        <!-- End Content Area -->

    </form>
</body>
</html>


<script>
    // Debounce utility function - Limit how often resizing is calculated for performance
    function debounce(func, wait) {
        let timeout;
        return function(...args) {
            const context = this;
            clearTimeout(timeout);
            timeout = setTimeout(() => func.apply(context, args), wait);
        };
    }

    // Dynamically calculate the height of the main content div
    function calculateMainContentHeight() {
    
        const vh = window.innerHeight;
        const navHeight = document.getElementById('nav-content').offsetHeight;
        const footerHeight = document.getElementById('footer-content').offsetHeight;
        const col2Height = document.getElementById('col-2').offsetHeight;
        
        // On larger screens only calculate main=vh-nav
        if (window.innerWidth > 992) {
            const mainHeight = vh - navHeight - footerHeight;
            document.getElementById('main-content').style.height = `${mainHeight}px`;
            return;  // Exit the function early
        }
        
        // Small screens calculate main=vh-nav-col2
        const mainHeight = vh - navHeight - footerHeight;
        document.getElementById('main-content').style.minHeight = `${mainHeight}px`;
    }

    // Add event listener to wait for all resources, including images, to load
    window.onload = function () {
        calculateMainContentHeight(); // initial calculation
        window.addEventListener('resize', debounce(calculateMainContentHeight, 250)); // debouncing with a 250ms wait time
    };
</script>