use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'WebService::TimeLine',
    VERSION_FROM => 'lib/WebService/TimeLine.pm', # finds $VERSION
    AUTHOR       => 'Masahiro Nagano (kazeburo@gmail.com)',
    ABSTRACT     => 'Perl interface to @nifty TimeLine API',
    PREREQ_PM    => {
                     'Test::Simple' => 0.44,
                     'LWP::UserAgent' => 0,
                     'XML::LibXML' => 0,
                    },
);
