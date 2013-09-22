use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'ColorThief',
	#license             => 'artistic2',
    license             => 'artistic_2',
    dist_author         => 'libitte <n@example.org>',
    dist_version_from   => 'lib/ColorThief.pm',
    requires => {
        'Test::More' => 0,
        'version'    => 0,
#		'Image::Magick' => 0,
    },
    add_to_cleanup      => [ 'ColorThief-*' ],
);

$builder->create_build_script();
