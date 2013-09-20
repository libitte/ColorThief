use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'ColorThief',
    AUTHOR              => 'libitte <n@example.org>',
    VERSION_FROM        => 'lib/ColorThief.pm',
    ABSTRACT_FROM       => 'lib/ColorThief.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'version'    => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'ColorThief-*' },
);
