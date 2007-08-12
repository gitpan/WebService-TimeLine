package WebService::TimeLine::Response;

use strict;
use warnings;
use base qw/HTTP::Response/;
use XML::LibXML;

sub result_node {
    my $self = shift;
    my $libxml = $self->libxml or return;
    my @node = $libxml->findnodes("/response/result");
    return $node[0];
}


sub api_status {
    my $self = shift;
    my $libxml = $self->libxml or return;
    my @node = $libxml->findnodes("/response/status");
    my %result = map { $_->nodeName => $_->to_literal } $node[0]->childNodes; 

    return \%result;
}

sub libxml {
    my $self = shift;
    return if ( $self->content !~ m!<\?xml version! );

    my $libxml = XML::LibXML->new();
    my $doc = $libxml->parse_string( $self->content );
    return $doc;
}

1;


