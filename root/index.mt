<?= $self->render('inc/header') ?>
<div id="main">
<h3>pixiv RSSとは？</h3>
<p>
   pixiv RSSとは、<a href="http://www.pixiv.net/" target="_blank">pixiv</a>の『[お気に入りユーザ or マイピク or 自分]の新着イラスト』のRSSを生成するサービスです。<br />
   <div align="right"><font size="2">by <a href="http://pixiv.cc/mix3/" target="_blank">mix3</a> (<a href="https://twitter.com/mix3" target="_blank">@mix3</a>)</font></div>
</p>
<form method="post" id="register">
? if(defined $s->{error}){
   <font color="#FF0000"><ul><li><?= $s->{error} ?></li></ul></font>
? }
   <p>
      <label for="user">pixiv ID:</label>
      <input type="text" id="pixiv_id" name="pixiv_id">
      <label for="pass">パスワード:</label>
      <input type="password" id="pixiv_pass" name="pixiv_pass">
      <input type="hidden" id="branch" name="branch" value="register" />
      <input type="submit" value="送信"/>
   </p>
</form>
<h3>使い方</h3>
   <p>
      pixivのID,パスワードを入力して送信します。<br />
      URLが生成されますので、RSSリーダーに登録してください。<br />
   </p>
</div>
<h3><font color="#FF0000">※注意</font></h3>
<p>
   本サービスは予告なく中止または内容を変更する場合もございます。<br />
   というか、その可能性が<font color="#FF0000"><b>超高い</b></font>です。あらかじめご了承ください。<br />
</p>
<h3>これから</h3>
<p>
   ＜未着手＞
   <ul>
      <li>ユーザによるURLの編集（ハッシュの部分を自由に設定）</li>
      <li>お気に入りタグのRSS生成</li>
   </ul>
   辺りをやっていきたい。
</p>
<p>
   ＜完了＞
   <ul>
      <li>キャッシュ（パフォーマンス的な意味で）　適当に巡回中</li>
      <li>キャッシュの定期削除（著作権的な意味で）　毎日不要なキャッシュを削除</li>
      <li>『マイピク新着イラスト』のRSS生成</li>
      <li>『登録ユーザ（＝自分）新着イラスト』のRSS生成</li>
   </ul>
</p>
<?= $self->render('inc/footer') ?>
