<?= $self->render('inc/header') ?>
<div id="main">
<p>
   以下のURLをRSSリーダーに登録してください。<br />
   <label for="user">RSS1.0:</label>
   <input type="text" name="text" id="text" size="100" value="<?= $s->{rss1_url} ?>" onfocus="this.select()">
   <label for="user">RSS2.0:</label>
   <input type="text" name="text" id="text" size="100" value="<?= $s->{rss2_url} ?>" onfocus="this.select()">
</p>
<form method="post" id="form">
   <input type="hidden" id="branch" name="branch" value="change" />
   <input type="submit" value="URLを作り直す"/>
</form>
</div>
<?= $self->render('inc/footer') ?>
