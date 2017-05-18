use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Docker::FakeInit',
    license             => 'perl',
    dist_author         => 'Steven Pritchard <steve@silug.org>',
    requires => {
        'Module::Build' => 0,
    },
);

$builder->create_build_script();

# vi: set ai et:
