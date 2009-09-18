use inc::Module::Install;
name 'NewPixivRSS';
all_from 'lib/NewPixivRSS.pm';

requires 'Ark';

tests 't/*.t';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
