package Catmandu::Exporter::Table;

our $VERSION = '0.1.2';

use namespace::clean;
use Catmandu::Sane;
use Moo;

with 'Catmandu::Exporter';

has fields => (
    is     => 'rw',
    trigger => 1,
);

has header => (
    is      => 'lazy',
    coerce  => \&_coerce_list,
    builder => sub { $_[0]->fields }
);

has widths => (
    is      => 'lazy',
    coerce  => \&_coerce_list,
    builder => sub {
        $_[0]->fixed_width(0);
        return [map { length $_ } @{$_[0]->header}]
    },
);

has fixed_width => (is => 'rw', default => sub { 1 });
has condense    => (is => 'ro');

# TODO: duplicated in Catmandu::Exporter::CSV fields-coerce
sub _coerce_list {
    if (ref $_[0]) {
        return $_[0] if ref $_[0] eq 'ARRAY';
        return [sort keys %{$_[0]}] if ref $_[0] eq 'HASH';
    }    
    return [split ',', $_[0]];
}

sub _trigger_fields {
    my ($self, $fields) = @_;
    $self->{fields} = _coerce_list($fields);
    if (ref $fields and ref $fields eq 'HASH') {
        $self->{header} = [ map { $fields->{$_} } @{$self->{fields}} ];
    }
}

sub add {
    my ($self, $data) = @_;
    unless ($self->fields) {
        $self->{fields} = [ sort keys %$data ]
    }
    my $fields = $self->fields;
    my $widths = $self->widths;
    my $row = [ ];

    foreach my $col (0..(@$fields-1)) {
        my $field = $fields->[$col];
        my $width = $widths->[$col];

        my $value = $data->{$field} // "";
        $value =~ s/[\n|]/ /g;

        my $w = length $value;
        if ($self->fixed_width) {
            if ($w > $width) {
                if ($width > 5) {
                    $value = substr($value, 0, $width-3) . '...';
                } else {
                    $value = substr($value, 0, $width);
                }
            }
        } else {
            $widths->[$col] = $w if $w > $width;
        }
        push @$row, $value;
    }

    push @{$self->{_rows}}, $row;
}

# TODO: support ugly Markdown table (no alignment)

sub commit {
    my ($self) = @_;

    my $fh      = $self->fh;
    my $widths  = $self->widths;
    my $header = $self->header;
#    my $line = '-' x (sum(@$widths) + 2*@$widths + 2) . "\n";
 
    $self->print_multimarkdown_row($self->header);
    map { print $fh "|".('-' x ($_+2))} @$widths;
    print $fh "|\n";

    $self->print_multimarkdown_row($_) for @{$self->{_rows}};
}

sub print_multimarkdown_row {
    my ($self, $row) = @_;
    my $fh     = $self->fh;
    my $widths = $self->widths;
    foreach my $col (0..(@$widths-1)) {
        printf $fh "| %-".$widths->[$col]."s ", $row->[$col];
    }
    print $fh "|\n";
}

=head1 NAME

Catmandu::Exporter::Table - ASCII/Markdown table exporter

=head1 SYNOPSIS

  echo '{"one":"my","two":"table"} {"one":"is","two":"nice"}]' | \ 
  catmandu convert JSON --multiline 1 to Table
  | one | two   |
  |-----|-------|
  | my  | table |
  | is  | nice  |

  catmandu convert CSV to Table --fields id,name --header ID,Name < sample.csv
  | ID | Name |
  |----|------|
  | 23 | foo  |
  | 42 | bar  |
  | 99 | doz  |

=head1 DESCRIPTION

This L<Catmandu::Exporter> exports data in tabular form, formatted in
MultiMarkdown syntax. The resulting format can be used for instance to display
CSV data or to include data tables in Markdown files. Newlines and vertical
bars in table cells are replaced by a space character and cell values can be
truncated.

=head1 CONFIGURATION

=over

=item fields

Array, hash reference, or comma-separated list of fields/columns.

=item header

Column names. By default field names are used.

=item widths

Column widths. By default column widths are calculated automatically to the
width of the widest value. With custom width, large values may be truncated.

=back

=head1 METHODS

See L<Catmandu::Exporter>, L<Catmandu::Addable>, L<Catmandu::Fixable>,
L<Catmandu::Counter>, and L<Catmandu::Logger> for a full list of methods.

=head1 SEE ALSO

L<Catmandu::Exporter::CSV>, L<Text::TabularDisplay>, L<Text::SimpleTable>, and
L<Text::Table>.

=cut

1;
