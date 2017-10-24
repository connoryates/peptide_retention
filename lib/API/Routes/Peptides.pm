package API::Routes::Peptides;

use Dancer ':syntax';
use Dancer::Exception qw(:all);
use Dancer::Plugin::Res;
use API::Plugins::Peptides;
use API::Plugins::KeyManager;
use API::X;

set serializer => 'JSON';

hook 'before' => sub {
    var 'authorized' => 1;

    return 1;
};

get '/api/v1/peptide/length/:length' => sub {
    my $length = param 'length' || undef;

    API::X->throw({
        message => "Missing required param : length",
        code    => 400,
    }) unless $length;

    my $data;
    try {
        $data = peptide_manager()->get_all({
            filter => {
                length => $length,
            },
        });
    } catch {
        API::X->throw({
            message => "Failed to get all peptides $_",
            code    => 500,
        });
    };

    return res 200, $data;
};

get '/api/v1/peptide/:peptide' => sub {
    my $peptide = param 'peptide' || undef;

    my $authorized = var 'authorized';

    API::X->throw({
        message => "Unauthorized",
        code    => 401,
    }) unless $authorized;

    API::X->throw({
        message => "Missing required param : peptide",
        code    => 500,
    }) unless $peptide;

    my $data;
    try {
        $data = peptide_manager()->retention_info($peptide);
    } catch {
        API::X->throw({
            message => "Failed to get retention info : $_",
            code    =>  500,
        });
    };

    return res 200, $data;
};

post '/api/v1/peptide/search' => sub {
    my $params = params || {};

    my $authorized = var 'authorized';

    API::X->throw({
        message => "Unauthorized",
        code    => 401,
    }) unless $authorized;

    my $limit  = $params->{limit};
    my $offset = $params->{offset};

    my $results;
    try {
        $results = peptide_manager()->search($params);
    } catch {
        API::X->throw({
            message => "Failed to get search results : $_",
            code    => 500,
        });
    };

    my $ret = {
        results => $results->{results},
        limit   => $limit,
        offset  => $offset // 0,
        next    => $results->{next},
    };

    return res 200, $ret;
};

any '/api/v1/peptide/search/next' => sub {
    my $params = params || {};

    my $authorized = var 'authorized';

    API::X->throw({
        message => "Unauthorized",
        code    => 401,
    }) unless $authorized;

    API::X->throw({
        message => "Missing required param : next (id)",
        code    => 400,
    }) unless $params->{next};

    my $results;
    try {
        $results = peptide_manager()->next($params->{next});
    } catch {
        API::X->throw({
            message => "Failed to get next results => $_",
            code => 500,
        });
    };

    return $results;
};

post '/api/v1/peptide/add' => sub {
    my $params = params || {};

    my $authorized = var 'authorized';

    API::X->throw({
        message => "Unauthorized",
        code    => 401
    }) unless defined $authorized;

    foreach my $required (qw(peptide retention_time prediciton_algorithm)) {
        API::X->throw({
            message => "Missing param : $required",
            code    => 500
        }) unless $params->{$required};
    }

    $params->{retention_info}->{prediction_info} = $params->{prediciton_algorithm};

    my $status;
    try {
        my $peptide_manager = peptide_manager();
           $status = $peptide_manager->add_retention_info($params);
    } catch {
        API::X->throw({
            message => "Failed to add retention info : $_",
            code    => 500
        });
    };

    return res 200, $status;
};

true;

=pod

=head1

get /api/v1/retention/peptide/:peptide

Returns:

     {
         "retention_info" : {
            "peptide" : "K",
            "predicted_retention" : -2.1,
            "prediction_algorithm" : "hodges",
            "bullbreese" : 0.46
         }
     }

=head1 post /api/v1/retention/peptide/add

NOTE: Need to adjust database schema to accept method param

Accepts parameters:

    {
        peptide              => $peptide,
        retention_time       => $retention_time, 
        prediciton_algorithm => $prediciton_algorithm,
    }

Returns:

    HTTP Status

=head1 post /api/v1/retention/peptide/search

Accepts parameters:

    {
        parameters => {
            keywords => 'mannosyltransferase',
            length   => 17,
            limit    => 100,
            offset   => 0
        },
    }

Returns:

    {
        results => [
            {
                'algorithm' => 'hodges',
                'primary_id' => 'sp|Q12150|CSF1_YEAST',
                'sequence' => 'VQISPISLFDVEVLVIR',
                'molecular_weight' => '1768.38',
                'cleavage' => 'tryptic',
                'protein_sequence' => 'MEAISQLRGVPLTHQKDFSWVFLVDWILTVVVCLTMIFYMGRIYAYLVSFILEWLLWKRAKIKINVETLRVSLLGGRIHFKNLSVIHKDYTISVLEGSLTWKYWLLNCRKAELIENNKSSSGKKAKLPCKISVECEGLEIFIYNRTVAYDNVINLLSKDERDKFEKYLNEHSFPEPFSDGSSADKLDEDLSESAYTTNSDASIVNDRDYQETDIGKHPKLLMFLPIELKFSRGSLLLGNKFTPSVMILSYESGKGIIDVLPPKERLDLYRNKTQMEFKNFEISIKQNIGYDDAIGLKFKIDRGKVSKLWKTFVRVFQIVTKPVVPKKTKKSAGTSDDNFYHKWKGLSLYKASAGDAKASDLDDVEFDLTNHEYAKFTSILKCPKVTIAYDVDVPGVVPHGAHPTIPDIDGPDVGNNGAPPDFALDVQIHGGSICYGPWAQRQVSHLQRVLSPVVSRTAKPIKKLPPGSRRIYTLFRMNISIMEDTTWRIPTRESSKDPEFLKHYKETNEEYRPFGWMDLRFCKDTYANFNISVCPTVQGFQNNFHVHFLETEIRSSVNHDILLKSKVFDIDGDIGYPLGWNSKAIWIINMKSEQLEAFLLREHITLVADTLSDFSAGDPTPYELFRPFVYKVNWEMEGYSIYLNVNDHNIVNNPLDFNENCYLSLHGDKLSIDVTVPRESILGTYTDMSYEISTPMFRMMLNTPPWNTLNEFMKHKEVGRAYDFTIKGSYLLYSELDIDNVDTLVIECNSKSTVLHCYGFVMRYLTNVKMNYFGEFFNFVTSEEYTGVLGAREVGDVTTKSSVADLASTVDSGYQNSSLKNESEDKGPMKRSDLKRTTNETDIWFTFSVWDGALILPETIYSFDPCIALHFAELVVDFRSCNYYMDIMAVLNGTSIKRHVSKQINEVFDFIRRNNGADEQEHGLLSDLTIHGHRMYGLPPTEPTYFCQWDINLGDLCIDSDIEFIKGFFNSFYKIGFGYNDLENILLYDTETINDMTSLTVHVEKIRIGLKDPVMKSQSVISAESILFTLIDFENEKYSQRIDVKIPKLTISLNCVMGDGVDTSFLKFETKLRFTNFEQYKDIDKKRSEQRRYITIHDSPYHRCPFLLPLFYQDSDTYQNLYGAIAPSSSIPTLPLPTLPDTIDYIIEDIVGEYATLLETTNPFKNIFAETPSTMEPSRASFSEDDNDEEADPSSFKPVAFTEDRNHERDNYVVDVSYILLDVDPLLFIFAKSLLEQLYSENMVQVLDDIEIGIVKRLSNLQEGITSISNIDIHIAYLNLIWQETGEEGFELYLDRIDYQMSEKSLEKNRTNKLLEVAALAKVKTVRVTVNQKKNPDLSEDRPPALSLGIEGFEVWSSTEDRQVNSLNLTSSDITIDESQMEWLFEYCSDQGNLIQEVCTSFNSIQNTRSNSKTELISKLTAASEYYQISHDPYVITKPAFIMRLSKGHVRENRSWKIITRLRHILTYLPDDWQSNIDEVLKEKKYTSAKDAKNIFMSVFSTWRNWEFSDVARSYIYGKLFTAENEKHKQNLIKKLLKCTMGSFYLTVYGEGYEVEHNFVVADANLVVDLTPPVTSLPSNREETIEITGRVGSVKGKFSDRLLKLQDLIPLIAAVGEDDKSDPKKELSKQFKMNTVLLVDKSELQLVMDQTKLMSRTVGGRVSLLWENLKDSTSQAGSLVIFSQKSEVWLKHTSVILGEAQLRDFSVLATTEAWSHKPTILINNQCADLHFRAMSSTEQLVTAITEIRESLMMIKERIKFKPKSKKKSQFVDQKINTVLSCYFSNVSSEVMPLSPFYIRHEAKQLDIYFNKFGSNEILLSIWDTDFFMTSHQTKEQYLRFSFGDIEIKGGISREGYSLINVDISISMIKLTFSEPRRIVNSFLQDEKLASQGINLLYSLKPLFFSSNLPKKEKQAPSIMINWTLDTSITYFGVLVPVASTYFVFELHMLLLSLTNTNNGMLPEETKVTGQFSIENILFLIKERSLPIGLSKLLDFSIKVSTLQRTVDTEQSFQVESSHFRVCLSPDSLLRLMWGAHKLLDLSHYYSRRHAPNIWNTKMFTGKSDKSKEMPINFRSIHILSYKFCIGWIFQYGAGSNPGLMLGYNRLFSAYEKDFGKFTVVDAFFSVANGNTSSTFFSEGNEKDKYNRSFLPNMQISYWFKRCGELKDWFFRFHGEALDVNFVPSFMDVIESTLQSMRAFQELKKNILDVSESLRAENDNSYASTSVESASSSLAPFLDNIRSVNSNFKYDGGVFRVYTYEDIETKSEPSFEIKSPVVTINCTYKHDEDKVKPHKFRTLITVDPTHNTLYAGCAPLLMEFSESLQKMIKKHSTDEKPNFTKPSSQNVDYKRLLDQFDVAVKLTSAKQQLSLSCEPKAKVQADVGFESFLFSMATNEFDSEQPLEFSLTLEHTKASIKHIFSREVSTSFEVGFMDLTLLFTHPDVISMYGTGLVSDLSVFFNVKQLQNLYLFLDIWRFSSILHTRPVQRTVNKEIEMSSLTSTNYADAGTEIPWCFTLIFTNVSGDVDLGPSLGMISLRTQRTWLATDHYNEKRQLLHAFTDGISLTSEGRLSGLFEVANASWLSEVKWPPEKSKNTHPLVSTSLNIDDIAVKAAFDYHMFLIGTISNIHFHLHNEKDAKGVLPDLLQVSFSSDEIILSSTALVVANILDIYNTIVRMRQDNKISYMETLRDSNPGESRQPILYKDILRSLKLLRTDLSVNISSSKVQISPISLFDVEVLVIRIDKVSIRSETHSGKKLKTDLQLQVLDVSAALSTSKEELDEEVGASIAIDDYMHYASKIVGGTIIDIPKLAVHMTTLQEEKTNNLEYLFACSFSDKISVRWNLGPVDFIKEMWTTHVKALAVRRSQVANISFGQTEEELEESIKKEEAASKFNYIALEEPQIEVPQIRDLGDATPPMEWFGVNRKKFPKFTHQTAVIPVQKLVYLAEKQYVKILDDTH',
                'real_retention_time' => undef,
                'length' => 17,
                'predicted_time' => '68.8',
                'bullbreese' => '-8.72'
            },
        ],
        limit => 100,
        offset => 0,
    }

=cut

1;
