package Module::Libs;
use strict;
use warnings;
use Cwd;
use FindBin;
use FindBin::libs;
use UNIVERSAL::require;

our $VERSION = '0.01';

my @PROJECT_ROOT_FILES = qw(
    .git
    .gitmodules
    Makefile.PL
);

sub import {
    my ($class, %args) = @_;
    my $current_dir = getcwd;

    my $lib_dirs           = delete $args{lib_dirs}           || [];
    my $project_root_files = delete $args{project_root_files} || [];

    push @PROJECT_ROOT_FILES, @$project_root_files;
    my @inc = find_inc($FindBin::Bin, $lib_dirs, ());

    if (scalar @inc) {
        my $inc = join ' ', @inc;
        eval "use lib qw($inc)";
    }

    chdir $current_dir;
}

sub find_inc {
    my ($current_dir, $lib_dirs, @inc) = @_;
    return @inc if $current_dir eq '/';
    chdir $current_dir;

    my @found = grep { -e File::Spec->catfile($current_dir, $_)} @$lib_dirs;
    push @inc, map { File::Spec->catfile($current_dir, $_)} @found;

    my @root_files = grep { -e $_ } @PROJECT_ROOT_FILES;
    if (!@root_files) {
        chdir '..';
        $current_dir = getcwd;
        return find_inc($current_dir, $lib_dirs, @inc);
    }

    for my $file (@root_files) {
        if ($file eq '.gitmodules') {
            push @inc, find_git_submodules(
                $current_dir,
                File::Spec->catfile($current_dir, '.gitmodules'),
            )
        }
    }

    @inc;
}

sub find_git_submodules {
    my ($current_dir, $gitsubmodule) = @_;
    open my $fh, "< $gitsubmodule" or die $!;
    my $content = do { local $/ = undef; <$fh> };
    close $fh;
    my @submodules = ($content =~ /\[submodule "([^"]+)"\]/g);
    map { File::Spec->catfile($current_dir, "$_/lib") } @submodules;
}

!!1;
