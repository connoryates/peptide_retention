package API::Routes::Upload;

use Dancer ':syntax';
use Dancer::Exception;
use API::Plugins::Upload;
use API::Plugins::KeyManager;
use API::X;

hook 'before' => sub {
    my $key_manager = key_manager();

    return 1;
};

post '/api/v1/upload' => sub {
     my $params = params || {};

     API::X->throw({
         message => "Missing file to upload",
         code    => 400
     }) unless defined $params->{file};

     my $status;
     try {
         my $upload_manager = upload_manager();
            $status = $upload_manager->upload($params->{file});
     } catch {
         API::X->throw({
             message => "Something went wrong",
             code    => 500
         });
     };

     return $status;
};

true;

=pod

=head1 post /api/v1/upload

REST route for upload files via HTTP. In development

=cut
