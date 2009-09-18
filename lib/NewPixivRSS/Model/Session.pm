package NewPixivRSS::Model::Session;
use Ark 'Model';

use Storable qw(retrieve nstore);

my $store_file = NewPixivRSS->path_to('tmp/session');

my %session;
if(-e $store_file){
   my $hashref = retrieve($store_file);
   %session = %$hashref;
}

sub get {
   my ($self, $key) = @_;
   if (my $session = $session{$key}) {
      return $session;
   }
}

sub set {
   my ($self, $key, $value) = @_;
   $session{$key} = $value;
   nstore \%session, $store_file;
}

sub remove {
   my ($self, $key) = @_;
   delete $session{$key};
}

1;
