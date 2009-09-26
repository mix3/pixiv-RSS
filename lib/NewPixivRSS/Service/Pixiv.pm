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
use YAML::Tiny;

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

sub add_user_to_image {
   my ($self, $user_id, $image_name) = @_;
   
   $self->schema->resultset('Usertoimage')->find_or_create({
      user_id     => $user_id,
      image_name  => $image_name,
   });
}

sub del_image_info {
   my $self = shift;
   my $user = shift;
   my @list = @_;
   
   my $rs = $self->schema->resultset('Usertoimage')->search(
      {
         user_id => $user,
         image_name => {'NOT IN' => \@list},
      },
   );
   $rs->delete;
}

sub del_image {
   my $self = shift;
   my $img_path = shift;
   
   my $rs = $self->schema->resultset('Image')->search(
      {
         'uti.user_id' => {IS => undef},
      },
      {
         from => [
            {me => 'Image'},
            [
               {uti => 'Usertoimage', -join_type => 'left'},
               {'me.name' => 'uti.image_name'}
            ]
         ],
         select   => ['me.name'],
         #as       => ['name'],
         group_by => ['me.name'],
      },
   );
   
   while(my $img = $rs->next){
      unlink $img_path.'/'.$img->name;
      warn $img->name, "\n";
   }
   $rs->delete;
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
