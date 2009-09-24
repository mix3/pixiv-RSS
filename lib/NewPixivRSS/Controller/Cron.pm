package NewPixivRSS::Controller::Cron;
use Ark 'Controller';

has '+namespace' => default => 'cron';

use Scrape;

sub round :Path('round') :Args(0) {
   my ($self, $c) = @_;
   
   $c->detach('/default') unless ($c->req->address =~ /^(127.0(.*)|192.168(.*))$/);
   
   my $user = $c->model('Pixiv')->get_next_user();
   
   my $scrape;
   eval {
      $scrape = Scrape->new({
         user           => $user->user,
         pass           => $user->pass,
         model          => $c->model('Pixiv'),
         img_url        => $c->uri_for('img')->as_string,
         save_img_path  => $c->app->path_to('root/img')->stringify,
      });
   };
   if($@){
      warn $user->user.": error\n";
      $c->res->body($user->user.': error');
   }else{
      warn $user->user, "\n";
      $scrape->round_image();
      $c->res->body($user->user.': ok');
   }
}

sub del :Path('del') :Args(0) {
   my ($self, $c) = @_;
   
   $c->detach('/default') unless ($c->req->address =~ /^(127.0(.*)|192.168(.*))$/);
   $c->res->body('ok');
}
 
1;
