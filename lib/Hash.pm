package Hash;

use Exporter;
use Digest::MD5 qw(md5_hex);

@ISA = (Exporter);
@EXPORT = qw(hashCalc);

sub hashCalc{
   return md5_hex($$, time(), rand(time));
}
