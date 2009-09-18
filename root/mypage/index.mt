<?= $self->render('inc/header') ?>
<div id="main">
<p>
   以下のURLをRSSリーダーに登録してください。<br />
   <dl>
      <p>
      <dt>お気に入りユーザ新着RSS</dt>
      <dd>
         <label for="user">RSS1.0:</label>
         <input type="text" name="text" id="text" size="100" value="<?= $s->{fav_rss1} ?>" onfocus="this.select()">
      </dd>
      <dd>
         <label for="user">RSS2.0:</label>
         <input type="text" name="text" id="text" size="100" value="<?= $s->{fav_rss2} ?>" onfocus="this.select()">
      </dd>
      </p>
      <p>
      <dt>マイピク新着RSS</dt>
      <dd>
         <label for="user">RSS1.0:</label>
         <input type="text" name="text" id="text" size="100" value="<?= $s->{mypic_rss1} ?>" onfocus="this.select()">
      </dd>
      <dd>
         <label for="user">RSS2.0:</label>
         <input type="text" name="text" id="text" size="100" value="<?= $s->{mypic_rss2} ?>" onfocus="this.select()">
      </dd>
      </p>
      <p>
      <dt>投稿新着RSS</dt>
      <dd>
         <label for="user">RSS1.0:</label>
         <input type="text" name="text" id="text" size="100" value="<?= $s->{own_rss1} ?>" onfocus="this.select()">
      </dd>
      <dd>
         <label for="user">RSS2.0:</label>
         <input type="text" name="text" id="text" size="100" value="<?= $s->{own_rss2} ?>" onfocus="this.select()">
      </dd>
      </p>
   </dl>
</p>
<form method="post" id="form">
   <input type="hidden" id="branch" name="branch" value="change" />
   <input type="submit" value="URLを作り直す"  onclick="return confirm('URLを作り直します。よろしいですか？')"/>
</form>
<form method="post" id="form">
   <input type="hidden" id="branch" name="branch" value="del" />
   <input type="submit" value="アカウントを削除する" onclick="return confirm('本当に削除してもよろしいですか？')"/>
</form>
</div>
<?= $self->render('inc/footer') ?>
