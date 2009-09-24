package NewPixivRSS::Model::Pixiv;
use Ark 'Model::Adaptor';

__PACKAGE__->config(
   class => 'NewPixivRSS::Service::Pixiv',
   args  => {
               connect_info   => ['dbi:SQLite:' . NewPixivRSS->path_to('db/pixivrss.db')],
               passphrase     => NewPixivRSS->config->{passphrase},
            },
   deref => 1,
);

1;
