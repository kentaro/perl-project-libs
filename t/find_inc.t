use strict;
use warnings;
use FindBin;
use File::Spec;
use Test::More;
use Module::Libs;

subtest 'find_inc' => sub {
    my @submodules = Module::Libs::find_inc($FindBin::Bin, [qw(extlib)], ());
    is_deeply \@submodules, [
        File::Spec->catfile($FindBin::Bin, 'extlib'),
        File::Spec->catfile($FindBin::Bin, 'modules/Plack/lib'),
        File::Spec->catfile($FindBin::Bin, 'modules/Devel-KYTProf/lib'),
    ];
    done_testing;
};

my $gitmodules = "$FindBin::Bin/.gitmodules";

subtest 'find_git_submodules' => sub {
    my @submodules = Module::Libs::find_git_submodules(
        $FindBin::Bin,
        File::Spec->catfile($FindBin::Bin, '.gitmodules'),
    );
    is_deeply \@submodules, [
        File::Spec->catfile($FindBin::Bin, 'modules/Plack/lib'),
        File::Spec->catfile($FindBin::Bin, 'modules/Devel-KYTProf/lib'),
    ];
    done_testing;
};

done_testing;
