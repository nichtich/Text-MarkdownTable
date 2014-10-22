package Text::MarkdownTable;
use strict;
use warnings;
use 5.010;

our $VERSION = '0.2.4';

use Moo;

has file => (
    is      => 'ro',
    lazy    => 1,
    default => sub { \*STDOUT },
);

use IO::File;
use IO::Handle::Util ();

has fh => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $fh = $_[0]->file;
        $fh = ref $fh 
            ? IO::Handle::Util::io_from_ref($fh) : IO::File->new($fh, "w");
        die "invalid option file" if !$fh;
        binmode $fh, $_[0]->encoding;
        $fh;
    }
);

has encoding => (
    is      => 'ro',
    default => sub { ':utf8' }
);

has fields => (
    is     => 'rw',
    trigger => 1,
);

# TODO: ensure that number of columns is number of fields
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
        return [map { defined($_) ? length $_ : 0 } @{$_[0]->columns}]
    },
);

has condense => (is => 'rw');

has _fixed_width => (is => 'rw', default => sub { 1 });
has _streaming => (is => 'rw');

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
        $self->{columns} = [ map { $fields->{$_} // $_ } @{$self->{fields}} ];
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

    if (!$self->_streaming) {
        if ($self->condense or $self->_fixed_width) {
            $self->_streaming(1);
            $self->_print_header;
        }
    }

    foreach my $col (0..(@$fields-1)) {
        my $field = $fields->[$col];
        my $width = $widths->[$col];

        my $value = $data->{$field} // "";
        $value =~ s/[\n|]/ /g;

        my $w = length $value;
        if ($self->_fixed_width) {
            if (!$width or $w > $width) {
                if ($width > 5) {
                    $value = substr($value, 0, $width-3) . '...';
                } else {
                    $value = substr($value, 0, $width);
                }
            }
        } else {
            $widths->[$col] = $w if !$width or $w > $width;
        }
        push @$row, $value;
    }

    $self->_add_row($row);
    $self;
}

sub _add_row {
    my ($self, $row) = @_;

    if ($self->_streaming) {
        $self->_print_row($row);
    } else {
        push @{$self->{_rows}}, $row;
    }
}

sub done {
    my ($self) = @_;

    if ($self->{_rows}) {
        $self->_print_header;
        $self->_print_row($_) for @{$self->{_rows}};
    }
}

sub _print_header {
    my ($self) = @_;
    my $fh     = $self->fh;

    $self->_print_row($self->columns);
    if ($self->condense) {
        $self->_print_row([ map { '-' x length $_ } @{$self->columns} ]);
    } else {
        print $fh '|'.('-' x ($_+2)) for @{$self->widths};
        print $fh "|\n";
    }
}

has _row_format => (
    is      => 'lazy',
    builder => sub { 
        $_[0]->condense
            ? join("|",map {"%s"} @{$_[0]->fields})."\n"
            : join("",map {"| %-".$_."s "} @{$_[0]->widths})."|\n";
    }
);

sub _print_row {
    my ($self, $row) = @_;
    printf {$self->fh} $self->_row_format, @{$row};
}

1;
__END__

=head1 NAME

Text::MarkdownTable - Write Markdown syntax tables from data

=head1 SYNOPSIS

  my $table = Text::MarkdownTable->new;
  $table->add({one=>"a",two=>"table"});
  $table->add({one=>"is",two=>"nice"});
  $table->done;

  | one | two   |
  |-----|-------|
  | a   | table |
  | is  | nice  |

=head1 DESCRIPTION

This module can be used to write data in tabular form, formatted in
MultiMarkdown syntax. The resulting format can be used for instance to display
CSV data or to include data tables in Markdown files. Newlines and vertical
bars in table cells are replaced by a space character and cell values can be
truncated.

=head1 CONFIGURATION

=over

=item file

Filename, GLOB, scalar reference or L<IO::Handle> to write to (default STDOUT).

=item fields

Array, hash reference, or comma-separated list of fields/columns.

=item columns

Column names. By default field names are used.

=item widths

Column widths. By default column widths are calculated automatically to the
width of the widest value. With given widths, the table is directly be written
without buffering and large table cell values are truncated.

=item condense

Write table unbuffered in condense format:

  one|two
  ---|---
  a|table
  is|nice

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

See L<Catmandu::Exporter::Table> for an application of this module that can be
used to easily convert data to Markdown tables.

Similar table-generating modules include:

=over

=item L<Text::Table::Tiny>

=item L<Text::TabularDisplay>

=item L<Text::SimpleTable>

=item L<Text::Table>

=item L<Text::ANSITable>

=item L<Text::ASCIITable>

=item L<Text::UnicodeBox::Table>

=item L<Table::Simple>

=item L<Text::SimpleTable>

=item L<Text::SimpleTable::AutoWidth>

=back

=encoding utf8

=head1 AUTHOR

Jakob Voß E<lt>jakob.voss@gbv.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2014- Jakob Voß

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
