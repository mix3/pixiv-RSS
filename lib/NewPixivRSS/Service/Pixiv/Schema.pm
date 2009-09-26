package NewPixivRSS::Service::Pixiv::Schema;

use strict;
use warnings;

use base 'DBIx::Class::Schema::Loader';
 
__PACKAGE__->loader_options(
	debug => 1,
	components => [qw(
		UTF8Columns
	)],
);
  
1;
