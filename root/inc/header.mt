<html>
<head>
<title>pixiv RSS</title>
<link rel="stylesheet" href="/css/base.css" type="text/css" />
<link rel="stylesheet" href="/css/style.css" type="text/css" />
</head>
<body>
<div id="container">
<div id="header">
<a href="<?= $c->uri_for('/') ?>"><img src="/img/logo.png" alt="pixiv RSS" id="logo" /></a>

<div id="login">
? if($c->user){
   <p>[<a href="<?= $c->uri_for('/logout') ?>">logout</a>]</p>
? } else {
   <form method="post" id="login">
      <p>
         <label for="user">ID:</label>
         <input type="text" id="pixiv_id" name="pixiv_id" />
         <label for="user">Pass:</label>
         <input type="password" id="pixiv_pass" name="pixiv_pass" />
         <input type="hidden" id="branch" name="branch" value="login" />
         <input type="submit" value="login" />
      </p>
   </form>
? }
</div>
<br clear="left">
</div>
