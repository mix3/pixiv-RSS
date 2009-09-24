package NewPixivRSS::Model::Session;
use Ark 'Model::Adaptor';

__PACKAGE__->config(
    class => 'Cache::FastMmap',
    args  => {
        share_file => NewPixivRSS->path_to('tmp/session')->stringify,
    },
);

1;
