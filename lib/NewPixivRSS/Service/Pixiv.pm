package NewPixivRSS::Service::Pixiv;

use Any::Moose;

use NewPixivRSS::Service::Pixiv::Schema;

has connect_info => (
	is			=> 'rw',
	isa		=> 'ArrayRef',
	required	=> 1,
);

has passphrase => (
   is       => 'rw',
   isa      => 'Str',
   required => 1,
);

has next_user => (
   is    => 'rw',
   isa   => 'Str',
);

has schema => (
	is => 'rw',
	isa => 'NewPixivRSS::Service::Pixiv::Schema',
	lazy => 1,
	default => sub {
		my $self = shift;
		NewPixivRSS::Service::Pixiv::Schema->connect( @{ $self->connect_info } );
	},
);

no Any::Moose;

use Hash;
use Crypt::RC4;
use Data::Dumper;

#use DateTime;
#use DateTime::Format::MySQL;

sub get_user{
	my ($self, $hash) = @_;
	if(my $result = $self->schema->resultset('User')->find($hash)){
	   $result->pass(_decrypt($self->passphrase, $result->pass));
	   return $result;
	}
	return;
}

sub add_user{
	my ($self, $user, $pass) = @_;
	
   $pass = _encrypt($self->passphrase, $pass);
   
   #my $result = $self->schema->resultset('User')->update_or_create(
   my $result = $self->schema->resultset('User')->find_or_create(
      {
         id    => hashCalc(),
         user  => $user,
         pass  => $pass,
      },{ key  => 'user_unique' }
   );
   $result->pass(_decrypt($self->passphrase, $result->pass));
   return $result;
}

sub change_id {
   my ($self, $hash) = @_;
   my $result = $self->schema->resultset('User')->find($hash);
   $result->update({id => hashCalc()});
}

sub del_user {
   my ($self, $hash) = @_;
   my $result = $self->schema->resultset('User')->search($hash)->delete();
}

sub get_image{
   my ($self, $url) = @_;
   $self->schema->resultset('Image')->find($url);
}

sub add_image{
   my ($self, $name, $title, $comment, $perma, $image) = @_;
   
   $self->schema->resultset('Image')->find_or_create({
      name    => $name,
      title   => $title,
      comment => $comment,
      perma   => $perma,
   });
}

sub get_next_user {
   my $self = shift;
   
   unless ($self->next_user){
      $self->next_user($self->schema->resultset('User')->search->first->user);
   }
   
   my $rs = $self->schema->resultset('User')->search;
   while($self->next_user ne $rs->next->user){
   }

   my $next;
   if(!($next = $rs->next)){
      my $user = $self->schema->resultset('User')->search->first;
      $next = $user;
   }
   $self->next_user($next->user);
   $next->pass(_decrypt($self->passphrase, $next->pass));
   return $next;
}

sub do_round {
   my $self = shift;
}

=comment
sub add_referer {
   my ($self, $ip, $url) = @_;

   return unless($ip);
   return unless($url);
   warn 'ip: ', $ip, "\n";
   warn 'url: ', $url, "\n";
   if($ip =~ /^192\.168\..*$|^127\.0\..*$/ || $url =~ /mix3\.(orz|moe)\.hm.*$/){
      return;
   }
   
   my $start = DateTime->now(
      time_zone   => 'Asia/Tokyo'
   );
   my $end = DateTime->now(
      time_zone   => 'Asia/Tokyo'
   );

   $start->set(hour => 0, minute => 0, second => 0);
   $end->set(hour => 23, minute => 59, second => 59);
   my $result = $self->schema->resultset('Referer')->search({
      ip    => $ip,
      url   => $url,
      date  => {
         -BETWEEN => [
            DateTime::Format::MySQL->format_datetime($start),
            DateTime::Format::MySQL->format_datetime($end)
         ]
      }
   });
   
   unless ($result->count){
      warn "not found\n";
      $self->schema->resultset('Referer')->create({
         ip    => $ip,
         url   => $url,
         date  => DateTime::Format::MySQL->format_datetime(
                     DateTime->now(time_zone => 'Asia/Tokyo')),
      });
   }else{
      warn "found\n";
   }
}

sub get_referer {
   my $self = shift;
   my $sub  = shift || 0;

   my $start = DateTime->now(
      time_zone   => 'Asia/Tokyo'
   );
   my $end = DateTime->now(
      time_zone   => 'Asia/Tokyo'
   );

   $start->set(hour => 0, minute => 0, second => 0);
   $end->set(hour => 23, minute => 59, second => 59);
   $start->subtract(days => $sub);
   $end->subtract(days => $sub);
   return $self->schema->resultset('Referer')->search({
      date => {
         -BETWEEN => [
            DateTime::Format::MySQL->format_datetime($start),
            DateTime::Format::MySQL->format_datetime($end)
         ]
      }
   });
}
=cut

sub _encrypt {
   my $passphrase = shift;
   my $plaintext  = shift;
   return RC4($passphrase, $plaintext);
}

sub _decrypt {
   my $passphrase = shift;
   my $encrypted  = shift;
   return RC4($passphrase, $encrypted);
}

sub _get_filename{
   my $url = shift;
   my @result = split(/\//, $url);
   return $result[-1];
}

1;
