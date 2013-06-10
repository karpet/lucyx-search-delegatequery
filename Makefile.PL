use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'LucyX::Search::DelegateQuery',
    AUTHOR              => q{Peter Karman <pkarman@cpan.org>},
    VERSION_FROM        => 'lib/LucyX/Search/DelegateQuery.pm',
    ABSTRACT_FROM       => 'lib/LucyX/Search/DelegateQuery.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'LucyX-Search-DelegateQuery-*' },
);
