package Text::MarkdownTable;
use strict;
use warnings;

our $VERSION = '0.2.0';

use Moo;

# copied from Catmandu::Exporter
has file => (
    is      => 'ro',
    lazy    => 1,
    default => sub { \*STDOUT },
);
 
use IO::File;
use IO::Handle::Util ();
use Scalar::Util ();

# copied from Catmandu::Exporter and Catmandu::Util
has fh => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $fh = $_[0]->file;

        if (ref $fh and Scalar::Util::reftype($fh) eq 'SCALAR') {
            $fh = IO::Handle::Util::io_from_scalar_ref($fh);
        } elsif (Scalar::Util::reftype(\$fh) eq 'GLOB' or
                (ref $fh and Scalar::Util::reftype($fh) eq 'GLOB')) {
            $fh = IO::Handle->new_from_fd($fh, "w") // $fh;
        } elsif (!ref $fh and length $fh > 0) {
            $fh = IO::File->new($fh, "w");
        } elsif (!Scalar::Util::blessed($fh) or !$fh->isa('IO::Handle')) {
            die "invalid value supplied to 'file'";
        }
        
        binmode $fh, $_[0]->encoding;
        return $fh;
    },
);

has encoding => (
    is      => 'ro',
    default => sub { ':utf8' }
);

has fields => (
    is     => 'rw',
    trigger => 1,
);

has columns => (
    is      => 'lazy',
    coerce  => \&_coerce_list,
    builder => sub { $_[0]->fields }
);

has widths => (
    is      => 'lazy',
    coerce  => \&_coerce_list,
    builder => sub {
        $_[0]->_fixed_width(0);
        return [map { length $_ } @{$_[0]->columns}]
    },
);

has _fixed_width => (is => 'rw', default => sub { 1 });

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
        $self->{columns} = [ map { $fields->{$_} } @{$self->{fields}} ];
    }
}

sub add {
    my ($self, $data) = @_;
    unless ($self->fields) {
        $self->{fields} = [ sort keys %$data ]
    }
    my $fields = $self->fields;
    my $widths = $self->widths; # may set 
    my $row = [ ];

    foreach my $col (0..(@$fields-1)) {
        my $field = $fields->[$col];
        my $width = $widths->[$col];

        my $value = $data->{$field} // "";
        $value =~ s/[\n|]/ /g;

        my $w = length $value;
        if ($self->_fixed_width) {
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

    $self;
}

# TODO: support ugly Markdown table (no alignment)

sub done {
    my ($self) = @_;

    my $fh      = $self->fh;
    my $widths  = $self->widths;
 
    $self->_print_multimarkdown_row($self->columns);
    map { print $fh "|".('-' x ($_+2))} @$widths;
    print $fh "|\n";

    $self->_print_multimarkdown_row($_) for @{$self->{_rows}};
}

sub _print_multimarkdown_row {
    my ($self, $row) = @_;
    my $fh     = $self->fh;
    my $widths = $self->widths;
    foreach my $col (0..(@$widths-1)) {
        printf $fh "| %-".$widths->[$col]."s ", $row->[$col];
    }
    print $fh "|\n";
}

=head1 NAME

Text::MarkdownTable - Write Markdown syntax tables from data

=head1 SYNOPSIS

  my $table = Text::MarkdownTable->new;
  $table->add_row({one=>"my",two=>"table"});
  $table->add_row({one=>"is",two=>"nice"});
  $table->done;

  | one | two   |
  |-----|-------|
  | my  | table |
  | is  | nice  |

=head1 DESCRIPTION

This module can be used to write data in tabular form, formatted in
MultiMarkdown syntax. The resulting format can be used for instance to display
CSV data or to include data tables in Markdown files. Newlines and vertical
bars in table cells are replaced by a space character and cell values can be
truncated.

=head1 CONFIGURATION

=over

=item fields

Array, hash reference, or comma-separated list of fields/columns.

=item columns

Column names. By default field names are used.

=item widths

Column widths. By default column widths are calculated automatically to the
width of the widest value. With custom width, large values may be truncated.

=back

=head1 METHODS

=over

=item add

Add a row as hash reference. Depending on the configuration rows are directly
written or buffered.

=item done

Finish and write the table unless it has already been written.

=back

=head1 SEE ALSO

This module is a fork of L<Catmandu::Exporter::Table>. See
L<Text::TabularDisplay>, L<Text::SimpleTable>, and L<Text::Table>,
L<Text::ANSITable>, and L<Text::ASCIITable> for similar modules.

=cut

1;
