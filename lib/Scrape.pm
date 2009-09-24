package Scrape;

use Any::Moose;

has 'user' => (
   is       => 'rw',
   isa      => 'Str',
   required => 1,
);

has 'pass' => (
   is       => 'rw',
   isa      => 'Str',
   required => 1,
);

has 'model' => (
   is       => 'rw',
   isa      => 'NewPixivRSS::Service::Pixiv',
   required => 1,
);

has 'img_url' => (
   is       => 'rw',
   isa      => 'Str',
   required => 1,
);

has 'save_img_path' => (
   is       => 'rw',
   isa      => 'Str',
   required => 1,
);

has 'mech'  => (
   is    => 'rw',
   isa   => 'WWW::Mechanize',
);

sub BUILD {
   my $self = shift;
   $self->_build_mech();
   return $self;
}

no Any::Moose;

use WWW::Mechanize;
use Web::Scraper;
use HTML::TreeBuilder::LibXML;
use YAML::Tiny;
use XML::RSS;

use utf8;
binmode(STDOUT, ":utf8");

sub _build_mech {
   my $self = shift;
   
   $self->mech(WWW::Mechanize->new());
   $self->mech->get('http://www.pixiv.net/');
   $self->mech->submit_form(
      fields => {
         pixiv_id => $self->user,
         pass => $self->pass,
      },
   );
}

sub check_login {
   my $self = shift;
   return 1 if($self->mech->uri() eq 'http://www.pixiv.net/mypage.php');
   return;
}

sub round_image {
   my $self = shift;
   
   $self->mech->get('http://www.pixiv.net/bookmark_new_illust.php');
   _get_image($self, _scraper('illust_c5'));
   $self->mech->get('http://www.pixiv.net/mypixiv_new_illust.php');
   _get_image($self, _scraper('illust_c5'));
   $self->mech->get('http://www.pixiv.net/member_illust.php');
   _get_image($self, _scraper('illust_c4'));
}

sub create_rss {
   my $self    = shift;
   my $kind    = shift;
   my $version = shift;
   
   if($kind eq 'fav'){
      $self->mech->get('http://www.pixiv.net/bookmark_new_illust.php');
      return _create_rss($version, 'pixiv RSS - ['.$self->user.'] お気に入りユーザ新着イラスト', _get_image($self, _scraper('illust_c5')));
   }elsif($kind eq 'mypic'){
      $self->mech->get('http://www.pixiv.net/mypixiv_new_illust.php');
      return _create_rss($version, 'pixiv RSS - ['.$self->user.'] マイピク新着イラスト', _get_image($self, _scraper('illust_c5')));
   }elsif($kind eq 'own'){
      $self->mech->get('http://www.pixiv.net/member_illust.php');
      return _create_rss($version, 'pixiv RSS - ['.$self->user.'] 新着イラスト', _get_image($self, _scraper('illust_c4')));
   }
}

=comment
sub create_rss_fav {
   my $self    = shift;
   my $version = shift;
   
   warn "fav\n";
   $self->mech->get('http://www.pixiv.net/bookmark_new_illust.php');
   _create_rss($version, _get_image($self, _scraper('illust_c5')));
}

sub create_rss_mypic {
   my $self    = shift;
   my $version = shift;
   
   warn "mypic\n";
   $self->mech->get('http://www.pixiv.net/mypixiv_new_illust.php');
   _create_rss($version, _get_image($self, _scraper('illust_c5')));
}

sub create_rss_own {
   my $self    = shift;
   my $version = shift;
   
   warn "own\n";
   $self->mech->get('http://www.pixiv.net/member_illust.php');
   warn _create_rss($version, _get_image($self, _scraper('illust_c4')));
}
=cut

sub _get_image {
   my $self    = shift;
   my $scraper = shift;
   
   my $result = $scraper->scrape($self->mech->content);
   
   #warn Dump $result;
   return () unless ($#{$result->{list}});
   
   my @list = ();
   foreach my $img (@{$result->{list}}){
      my $name = _get_filename($img->{img_url});
      my @del = split('_', $name);
      next if($#del > 1);
      
      my $image = $self->model->get_image($name);
      if(! defined $image){
         warn " $name... downloading!\n";
         warn $self->save_img_path.'/'.$name."\n";
         eval {
            $self->mech->get($img->{img_url}, ':content_file' => $self->save_img_path.'/'.$name);
         };
         if($@){
            warn 'download error...', "\n";
            next;
         }
         my $info = _get_info($self, $img->{post_url});
         $self->model->add_image($name, $info->{title}, $info->{comment}, $img->{post_url});
         $image = $self->model->get_image($name);
      }else{
         warn " $name... exist!\n";
      }
      push(@list, {title => $image->title, comment => $image->comment, url=>$image->perma, img_url => $self->img_url.'/'.$name});
   }
   return @list;
}

sub _scraper {
   my $id = shift;
   return scraper {
      process '//div[@id="'.$id.'"]/ul/li', 'list[]' => scraper{
         process '//a[1]/img', 'img_url' => sub {
            my $url = $_->attr('src');
            $url =~ s/^(.*?)(_s\.)(.*)$/$1_m\.$3/g;
            return $url;
         };
         process '//a[1]', 'post_url' => sub{
            return 'http://www.pixiv.net/'.$_->attr('href');
         };
      };
   };
}

sub _create_rss{
   my $version = shift;
   my $title   = shift;
   my @list    = @_;

   #my $rss = XML::RSS->new(version => '2.0', encode_output => 0);
   my $rss = XML::RSS->new(version => $version);
   $rss->channel(
      title => '<![CDATA['.$title.']]>',
      link  => "http://mix3.moe.hm/pixiv_rss/",
      description => '<![CDATA['.$title.']]>',
   );

   foreach my $img (@list){
      my $title = Encode::decode('utf8', $img->{title}) || "";
      my $comment = Encode::decode('utf8', $img->{comment}) || "";
      $rss->add_item(
         title => '<![CDATA['.$title.']]>',
         link => $img->{url},
         description => '<![CDATA['."$comment<br /><a href=\"$img->{url}\" target=\"_blank\"><img src=\"$img->{img_url}\" /></a><br />".']]>',
      );
   }
   return $rss->as_string;
   #return $rss;
}


sub _get_info{
   my ($self, $url) = @_;

   my $scraper = scraper{
      process '//div[@class="f18b"]', 'title' => 'TEXT';
      process '//div[@id="illust_comment"]', 'comment' => 'TEXT';
      process '//div[@id="content2"]/div/a/img', 'url' => '@src';
   };
   $self->mech->get($url);

   return $scraper->scrape($self->mech->content);
}

sub _get_filename{
   my $url = shift;
   my @result = split(/\//, $url);
   return $result[-1];
}

1;
