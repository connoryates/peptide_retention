package API::Routes::Upload;

use Dancer ':syntax';
use Dancer::Exception;
use API::Plugins::Upload;

hook 'before' => sub {
    my $key_manager = key_manager();

    return 1;
};

post '/api/v1/upload' => sub {
     my $params = params || {};

     send_error("Missing file to upload" => 400) unless defined $params->{file};

     my $status;
     try {
         my $upload_manager = upload_manager();
            $status = $upload_manager->upload($params->{file});
     } catch {
         send_error("Something went wrong" => 500);
     };

     return $status;
};


true;
