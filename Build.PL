use strict;
use warnings;

use Module::Build;

my $build = Module::Build->new(
    module_name         => 'Evented::Configuration',
    dist_author         => 'Mitchell Cooper <cooper@cpan.org>',
    dist_abstract       => 'an evented configuration file in a unique and clean format',
    requires            => { perl => '5.010' },
    recommends          => {},
    build_requires      => {},
    license             => 'bsd',
    create_makefile_pl  => 'traditional',
    # create_license    => 1,
    # create_readme     => 1,
    dynamic_config      => 0,
    meta_merge          => {
        resources => {
            repository => 'https://github.com/cooper/evented-configuration'
        }
    },
);

$build->create_build_script;
