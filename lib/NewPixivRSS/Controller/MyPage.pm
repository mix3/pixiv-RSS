package NewPixivRSS::Controller::MyPage;
use Ark 'Controller';

has '+namespace' => default => 'mypage';

use Data::Dumper;

sub index :Path :Args(0) {
   my ($self, $c) = @_;
   
   if($c->user && $c->req->method eq 'POST'){
      if($c->req->param('branch') eq 'change'){
         $c->detach('change');
      }elsif($c->req->param('branch') eq 'del'){
         $c->detach('del');
      }
   }
   
   unless ($c->user) {
      warn "not login...\n";
      
      $c->redirect($c->uri_for('/'));
   }else{
      warn "login\n";
      
      my $user = $c->model('Pixiv')->get_user({user => $c->user->hash->{user}});
      $c->stash->{fav_rss1}   = $c->uri_for('/'.$user->id.'/fav/rss');
      $c->stash->{fav_rss2}   = $c->uri_for('/'.$user->id.'/fav/rss2');
      $c->stash->{mypic_rss1} = $c->uri_for('/'.$user->id.'/mypic/rss');
      $c->stash->{mypic_rss2} = $c->uri_for('/'.$user->id.'/mypic/rss2');
      $c->stash->{own_rss1}   = $c->uri_for('/'.$user->id.'/own/rss');
      $c->stash->{own_rss2}   = $c->uri_for('/'.$user->id.'/own/rss2');
   }
}

sub change :Private {
   my ($self, $c) = @_;
   $c->model('Pixiv')->change_id({user => $c->user->hash->{user}});
   $c->redirect($c->uri_for('/mypage'));
}

sub del :Private {
   my ($self, $c) = @_;
   $c->model('Pixiv')->del_user({user => $c->user->hash->{user}});
   $c->redirect($c->uri_for('/logout'));
}

1;
