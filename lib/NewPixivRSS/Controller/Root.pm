package NewPixivRSS::Controller::Root;
use Ark 'Controller';

has '+namespace' => default => '';

use Scrape;
use Data::Dumper;
use XML::RSS;

# default 404 handler
sub default :Path :Args {
    my ($self, $c) = @_;

    $c->res->status(404);
    $c->res->body('404 Not Found');
}

sub end :Private {
   my ($self, $c) = @_;

   unless ($c->res->body or $c->res->status =~ /^3\d\d/){
      $c->forward($c->view('MT'));
   }
}

sub logout :Global {
   my ($self, $c) = @_;
   $c->logout;
   $c->redirect( $c->uri_for('/') );
}

sub index :Path :Args(0) {
   my ($self, $c) = @_;
   
   if($c->user){
      $c->redirect( $c->uri_for('/mypage') );
   }
   
   if($c->req->method eq 'POST'){
      if($c->req->param('branch') eq 'register'){
         $c->forward('register');
      }elsif($c->req->param('branch') eq 'login'){
         $c->forward('login');
      }
   }
   
   #warn NewPixivRSS->path_to('tmp/erferer');
   open OUT, '>>  '.NewPixivRSS->path_to('tmp/erferer');
   if(defined $c->req->referer){
      print OUT $c->req->referer, "\n";
   }
   close OUT;
}

sub register :Private {
   my ($self, $c) = @_;
   
   if (my $user = $c->authenticate) {
      my $register = $c->model('Pixiv')->add_user(
         $user->hash->{user},
         $user->hash->{pass}
      );
      $c->redirect( $c->uri_for('/mypage') );
   }
   $c->stash->{error} = "ID、パスワードのいずれかが違います。";
}

sub login :Private {
   my ($self, $c) = @_;
   
   if($c->model('Pixiv')->get_user({user => $c->req->param('pixiv_id')})){
      if(my $user = $c->authenticate){
         $c->redirect( $c->uri_for('/mypage') );
      }
   }   
}

sub rss :Chained('kind') :PathPart('') :Args(1) {
   my ($self, $c, $rss) = @_;
   
   if($rss !~ /^(rss|rss2)$/){
      $c->detach('default');
   }
   
   my $scrape;
   eval {
      $scrape = Scrape->new({
         user  => $c->stash->{user}->user,
         pass  => $c->stash->{user}->pass,
         model => $c->model('Pixiv'),
      });
   };
   
   if($@){
      $c->detach('meinte');
   }
   
   my $ver;
   if($rss eq 'rss'){
      $ver = '1.0';
   }elsif($rss eq 'rss2'){
      $ver = '2.0';
   }
   
   $c->res->headers->content_type('application/xml');
   $c->res->body($scrape->create_rss($c->stash->{kind}, $ver));
}

sub kind :Chained('rdf') :PathPart('') :CaptureArgs(1) {
   my ($self, $c, $kind) = @_;
   
   if($kind !~ /^(fav|mypic|own|index.rdf)$/){
      $c->detach('default');
   }
   
   $c->stash->{kind} = $kind;
   
}

sub meinte :Private {
   my ($self, $c) = @_;

   my $rss = new XML::RSS({version => '1.0'});
   $rss->channel(
      title => '<![CDATA['."pixiv RSS".']]>',
      link  => "http://mix3.moe.hm/pixiv_rss/",
      description => '<![CDATA['."pixiv の RSS 化".']]>',
   );
   $rss->add_item(
      title => '<![CDATA[pixivメンテナンスの可能性]]>',
      link => 'http://mix3.moe.hm/pixiv_rss/',
      description => '<![CDATA[ただいまpixivがメンテナンス中の可能性があります。しばらくお待ちください。]]>',
   );

   $c->res->headers->content_type('application/xml');
   $c->res->body($rss->as_string);
}

sub move :Chained('rdf') :PathPart('index.rdf') :Args(0) {
   my ($self, $c) = @_;
   
   my $rss = new XML::RSS({version => '1.0'});
   $rss->channel(
      title => '<![CDATA['."pixiv RSS [跡地]".']]>',
      link  => "http://mix3.moe.hm/pixiv_rss/",
      description => '<![CDATA['."pixiv の RSS 化 [跡地]".']]>',
   );
   $rss->add_item(
      title => '<![CDATA[【重要】サービスの更新につき、RSSのアドレスが変更されています！]]>',
      link => 'http://mix3.moe.hm/pixiv_rss/',
      description => '<![CDATA[【重要】サービスの更新につき、RSSのアドレスが変更されています！<br />'.
                     'アカウント情報は保持されていますので、トップページよりログインしていただき、'.
                     'URLをご確認のうえ、再度RSSリーダーへの登録をお願いします。]]>',
   );
   
   $c->res->headers->content_type('application/xml');
   $c->res->body($rss->as_string);
}

sub rdf :Chained('/') :PathPart('') :CaptureArgs(1) {
   my ($self, $c, $hash) = @_;
   
   my $user = $c->model('Pixiv')->get_user({id => $hash});
   if(!$user){
      $c->detach('default');
   }
   $c->stash->{user} = $user;
   $c->stash->{hash} = $hash;
}

1;
k
