package WebService::TimeLine;

use strict;
use warnings;
use LWP::UserAgent;
use WebService::TimeLine::Response;
use Carp;

our $VERSION     = '0.01';
our $APIROOT = "http://api.timeline.nifty.com/api/v1";

sub new {
    my $class = shift;
    my $self = { @_ };
    bless $self, $class;
    $self->{timeline_key} || Carp::croak "no timeline_key defined";
    $self->{agent}        ||= LWP::UserAgent->new;
    $self;
}

sub response_error {
    my ($self, $res) = @_;
    my $status = $res->api_status;
    if( ! defined $status ) {
        $self->errcode($res->code);
        $self->errstr($res->status_line);
    }
    else {
        $self->errcode($status->{code});
        $self->errstr($status->{message});
    }
}

sub errstr {
    my $self = shift;
    if ( @_ ) {
        $self->{errstr} = shift;
    }
    $self->{errstr};
}

sub errcode {
    my $self = shift;
    if ( @_ ) {
        $self->{errcode} = shift;
    }
    $self->{errcode};
}

sub post {
    my $self = shift;
    my $res = $self->{agent}->post(
        @_
    );
    bless $res, 'WebService::TimeLine::Response';
    $res;
}

sub show_timeline {
    my $self = shift;
    my $id   = shift;

    my $res = $self->post(
        $APIROOT . '/timelines/show/' . $id,
        [
            timeline_key => $self->{timeline_key},
        ]
    );
    return $self->response_error($res) unless $res->is_success;

    my @timeline = $res->result_node->findnodes("//result/timeline");
    my %timeline = map { $_->nodeName => $_->to_literal } $timeline[0]->childNodes; 

    return \%timeline;
}

sub search_timeline {
    my $self = shift;
    
    my $res = $self->post(
        $APIROOT . '/timelines/search',
        [
            @_,
            timeline_key => $self->{timeline_key},
        ]
    );

    return $self->response_error($res) unless $res->is_success;
    my $result = $res->result_node;

    my @summary = $result->findnodes("//result/summary");
    my %summary = map { $_->nodeName => $_->to_literal } $summary[0]->childNodes; 

    my @timelines;
    foreach my $timeline ( $result->findnodes('//result/timelines/timeline') ) {
        my %timeline = map { $_->nodeName => $_->to_literal  } $timeline->childNodes;
        push @timelines, \%timeline;
    }

    return wantarray ? (\@timelines, \%summary) : \@timelines;
}

sub create_timeline {
    my $self = shift;
    my $res = $self->post(
        $APIROOT . '/timelines/create',
        [
            @_,
            timeline_key => $self->{timeline_key},
        ]
    );
    return $self->response_error($res) unless $res->is_success;

    my @timeline = $res->result_node->findnodes("//result/timeline");
    my %timeline = map { $_->nodeName => $_->to_literal } $timeline[0]->childNodes; 

    return \%timeline;
}

sub update_timeline {
    my $self = shift;
    my $id   = shift;

    my $res = $self->post(
        $APIROOT . '/timelines/update/' . $id,
        [
            @_,
            timeline_key => $self->{timeline_key},
        ]
    );
    return $self->response_error($res) unless $res->is_success;

    my @timeline = $res->result_node->findnodes("//result/timeline");
    my %timeline = map { $_->nodeName => $_->to_literal } $timeline[0]->childNodes; 

    return \%timeline;
}

sub delete_timeline {
    my $self = shift;
    my $id   = shift;
    my $res = $self->post(
        $APIROOT . '/timelines/delete/' . $id,
        [
            timeline_key => $self->{timeline_key},
        ]
    );
    return $self->response_error($res) unless $res->is_success;
    return 1;
}



sub show_article {
    my $self = shift;
    my $id   = shift;

    my $res = $self->post(
        $APIROOT . '/articles/show/' . $id,
        [
            timeline_key => $self->{timeline_key},
        ]
    );

    return $self->response_error($res) unless $res->is_success;

    my @article = $res->result_node->findnodes("//result/article");
    my %article = map { $_->nodeName => $_->to_literal } $article[0]->childNodes; 

    return \%article;
}

sub search_article {
    my $self = shift;
     
    my $res = $self->post(
        $APIROOT . '/articles/search',
        [
            @_,
            timeline_key => $self->{timeline_key},
        ]
    );

    return $self->response_error($res) unless $res->is_success;
    my $result = $res->result_node;

    my @summary = $result->findnodes("//result/summary");
    my %summary = map { $_->nodeName => $_->to_literal } $summary[0]->childNodes; 

    my @articles;
    foreach my $article ( $result->findnodes('//result/articles/article') ) {
        my %article = map { $_->nodeName => $_->to_literal  } $article->childNodes;
        push @articles, \%article;
    }

    return wantarray ? ( \@articles, \%summary ) : \@articles;
}

sub create_article {
    my $self = shift;
    my $res = $self->post(
        $APIROOT . '/articles/create',
        [
            @_,
            timeline_key => $self->{timeline_key},
        ]
    );

    return $self->response_error($res) unless $res->is_success;
    my @article = $res->result_node->findnodes("//result/article");
    my %article = map { $_->nodeName => $_->to_literal } $article[0]->childNodes; 

    return \%article;
}

sub update_article {
    my $self = shift;
    my $id   = shift;

    my $res = $self->post(
        $APIROOT . '/articles/update/' . $id,
        [
            @_,
            timeline_key => $self->{timeline_key},
        ]
    );
    return $self->response_error($res) unless $res->is_success;
    my @article = $res->result_node->findnodes("//result/article");
    my %article = map { $_->nodeName => $_->to_literal } $article[0]->childNodes; 

    return \%article;
}

sub delete_article {
    my $self = shift;
    my $id   = shift;
    my $res = $self->post(
        $APIROOT . '/articles/delete/' . $id,
        [
            timeline_key => $self->{timeline_key},
        ]
    );
    return $self->response_error($res) unless $res->is_success;
    return 1;
}

1;

__END__

=head1 NAME

WebService::TimeLine - Perl interface to @nifty TimeLine API

=head1 SYNOPSIS

 use WebService::TimeLine;
 
 my $wt = WebService::TimeLine->new( timeline_key => 'your_timeline_key' );
 my $timeline = $wt->create_timeline(
   title       => 'perl timeline',
   description => 'perl test timeline',
   label_for_vaxis => 'test',
 ) or die $wt->errstr;

 my $timeline_id = $timeline->{id};
 my $dt = DateTime->now( time_zone =>'Asia/Tokyo' );

 $res = $wt->create_article(
   timeline_id => $timeline_id,
   title       => 'perl article',
   description => 'perl test article',
   start_time  => DateTime::Format::W3CDTF->format_datetime($dt),
   end_time    => DateTime::Format::W3CDTF->format_datetime($dt),
   grade       => 0,
 ) or die $wt->errstr;

=head1 DESCRIPTION

This module is Perl interface to @nifty Timeline API. For more information, visite the @nifty website L<http://timeline.nifty.com/> and online documents L<http://webservice.nifty.com/timeline/>

=over 4

=item new( timeline_key => $key )

Create instance

=item errstr

   my $timeline = $wt->show_timeline( 'id' ) or die $wt->errstr;

Get a error message

=item errcode

   my $timeline = $wt->show_timeline( 'id' ) or die $wt->errcode;

Get a error code

=item show_timeline($id)

  my $timeline = $wt->show_timeline( 'id' );
  my $title = $timeline->{title};

Retrive a timeline.

=item search_timeline(%args)

  my ($timelines, $summary) = $wt->search_timeline( phrase => 'perl' );
  my $total = $summary->{total};
  foreach my $timeline ( @$timelines ) {
    $timeline->{id};
  }

Search timelines

=item create_timeline(%args)

  my $timeline = $wt->create_timeline(
    title => 'title',
    description => 'description',
    label_for_vaxis => 'vaxis',
  );
  
Create a timeline

=item update_timeline( $id, %args )

  my $timeline = $wt->update_timeline(
    $id,
    title => 'title',
    description => 'description',
    label_for_vaxis => 'vaxis',
  );

Update a timeline

=item delete_timeline($id);

  $wt->update_timeline( $id );

Delete a timeline

=item show_article($id)

  my $article = $wt->show_article($id);
  my $title = $article->{title};

Retrive article

=item search_article( %args )

  my ($articles, $summary) = $wt->search_article(
    timeline_id => $timeline_id
  );
  my $page_count = $summary->{page_count};
  foreach my $article ( @$articles ) {
    $article->{title}
  }
    
Search articles

=item create_article( %args )

  my $article = $wt->create_article(
    timeline_id => $timeline_id,
    title => 'title',
    description => 'description',
    start_time => '2007-02-27T10:43:29+09:00',
    end_time   => '2007-02-27T10:43:29+09:00',
    grade      => $grade
  );

Create a article

=item update_article( $id, %args )

  my $article = $wt->update_article(
    $id,
    title => 'new title',
  );

Update a article

=item delete_article( $id )

  $wt->delete_article( $id );

Delete a article

=back

=head1 SEE ALSO

L<http://timeline.nifty.com/>, L<http://webservice.nifty.com/timeline/>

=head1 AUTHOR

Masahiro Nagano C<< <<kazeburo@gmail.com>> >>

=head1 COPYRIGHT

Copyright (c) 2007 by Masahiro Nagano

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.


=cut

