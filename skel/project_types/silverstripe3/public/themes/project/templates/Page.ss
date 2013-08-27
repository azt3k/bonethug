<!DOCTYPE html>

<!--[if !IE]><!-->
<html lang="$ContentLocale">
<!--<![endif]-->
<!--[if IE 6 ]><html lang="$ContentLocale" class="ie ie6"><![endif]-->
<!--[if IE 7 ]><html lang="$ContentLocale" class="ie ie7"><![endif]-->
<!--[if IE 8 ]><html lang="$ContentLocale" class="ie ie8"><![endif]-->

  <head>

    <% base_tag %>

    <title><% if $MetaTitle %>$MetaTitle<% else %>$Title<% end_if %> &raquo; $SiteConfig.Title</title>

    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    $MetaTags(false)

    <!--[if lt IE 9]>
      <script src="//html5shiv.googlecode.com/svn/trunk/html5.js"></script>
    <![endif]-->

    <% require themedCSS('reset') %>
    <% require themedCSS('typography') %>
    <% require themedCSS('form') %>
    <% require themedCSS('layout') %>

    <link rel="icon" type="image/png" href="themes/project/images/favicon.png">
    <link rel="apple-touch-icon" type="image/png" href="themes/project/images/apple-touch-icon.png">
    <link rel="apple-touch-icon-precomposed" sizes="114x114" href="themes/project/images/apple-touch-icon-72x72-precomposed.png">
    <link rel="apple-touch-icon-precomposed" sizes="72x72" href="themes/project/images/apple-touch-icon-114x114-precomposed.png">

  </head>
  <body>

    <div class="navbar">
      <div class="container">

        <!-- .navbar-toggle is used as the toggle for collapsed navbar content -->
        <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-responsive-collapse">
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
        </button>

        <!-- Be sure to leave the brand out there if you want it shown -->
        <a class="navbar-brand" href="#">Title</a>

        <!-- Place everything within .nav-collapse to hide it until above 768px -->
        <div class="nav-collapse collapse navbar-responsive-collapse">
          <ul class="nav navbar-nav">
            <% loop Menu(1) %>
              <li class="<% if $LinkingMode == 'current' %>active<% end_if %>"><a href="$Link">$MenuTitle</a></li>
            <% end_loop %>    
          </ul>
        </div><!-- /.nav-collapse -->

      </div><!-- /.container -->
    </div><!-- /.navbar --> 

    <div class="container">
      $Layout
    </div>
    
  </body>

</html>