package Catmandu::Exporter::Table;

use Catmandu::Sane;
use Moo;
use List::Util qw(sum);

with 'Catmandu::Exporter';

has fields => (
    is     => 'rw',
    coerce => sub {
        my $fields = $_[0];
        if (ref $fields eq 'ARRAY') { return $fields }
        # TODO: use as columns
        if (ref $fields eq 'HASH')  { return [sort keys %$fields] }
        return [split ',', $fields];
    },
);

has columns => (
    is      => 'rw',
    lazy    => 1,
    builder => sub { $_[0]->fields } # TODO: coerce
);

has widths => (
    is => 'ro',
    lazy => 1,
    builder => sub {
        [map { length $_ } @{$_[0]->columns}]
    }
);

sub add {
    my ($self, $data) = @_;
    my $fields = $self->fields || $self->fields($data);
    my $row = [map {
        my $val = $data->{$_} // "";
        $val =~ s/\n/ /g;
        $val =~ s/\|/\\|/g;
        $val;
    } @$fields];

    my $widths = $self->widths;
    foreach my $col (0..(@$fields-1)) {
        my $w = length $row->[$col];
        $widths->[$col] = $w if $w > $widths->[$col];
    }

    push @{$self->{_rows}}, $row;
}

# TODO: support ugly Markdown table (no alignment)

sub commit {
    my ($self) = @_;

    my $fh      = $self->fh;
    my $widths  = $self->widths;
    my $columns = $self->columns;
#    my $line = '-' x (sum(@$widths) + 2*@$widths + 2) . "\n";
 
    $self->print_row($self->columns);
    map { print $fh "|".('-' x ($_+2))} @$widths;
    print $fh "|\n";

    $self->print_row($_) for @{$self->{_rows}};
}

sub print_row {
    my ($self, $row) = @_;
    my $fh     = $self->fh;
    my $widths = $self->widths;
    foreach my $col (0..(@$widths-1)) {
        printf $fh "| %-".$widths->[$col]."s ", $row->[$col];
    }
    print $fh "|\n";
}

=head1 NAME

Catmandu::Exporter::Table - export as ASCII/Markdown table

=head1 SYNOPSIS

  echo '{"one":"my","two":"table"} {"one":"is","two":"nice"}]' | \ 
  catmandu convert JSON --multiline 1 to Table
  | one | two   |
  |-----|-------|
  | my  | table |
  | is  | nice  |

=head1 DESCRIPTION

This L<Catmandu::Exporter> exports data in tabular form, formatted in
MultiMarkdown syntax. The resulting format can be used for instance to display
CSV data or to include data tables in Markdown files.

=head1 CONFIGURATION

=over

=item fields

Array, hash reference, or comma-separated list of fields/columns.

=back

=head1 SEE ALSO

Parts of this module have been copied from L<Catmandu::Exporter::CSV>.

=cut

1;
