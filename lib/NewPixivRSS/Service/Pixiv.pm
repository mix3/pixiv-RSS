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

has path_img => (
   is       => 'rw',
   isa      => 'Str',
   required => 1,
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
