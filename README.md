# NAME

Text::MarkdownTable - Write Markdown syntax tables from data

# SYNOPSIS

    my $table = Text::MarkdownTable->new;
    $table->add({one=>"a",two=>"table"});
    $table->add({one=>"is",two=>"nice"});
    $table->done;

    | one | two   |
    |-----|-------|
    | a   | table |
    | is  | nice  |

# DESCRIPTION

This module can be used to write data in tabular form, formatted in
MultiMarkdown syntax. The resulting format can be used for instance to display
CSV data or to include data tables in Markdown files. Newlines and vertical
bars in table cells are replaced by a space character and cell values can be
truncated.

# CONFIGURATION

- file

    Filename, GLOB, scalar reference or [IO::Handle](https://metacpan.org/pod/IO::Handle) to write to (default STDOUT).

- fields

    Array, hash reference, or comma-separated list of fields/columns.

- columns

    Column names. By default field names are used.

- widths

    Column widths. By default column widths are calculated automatically to the
    width of the widest value. With given widths, the table is directly be written
    without buffering and large table cell values are truncated.

- condense

    Write table unbuffered in condense format:

        one|two
        ---|---
        a|table
        is|nice

# METHODS

- add

    Add a row as hash reference. Depending on the configuration rows are directly
    written or buffered.

- done

    Finish and write the table unless it has already been written.

# SEE ALSO

See [Catmandu::Exporter::Table](https://metacpan.org/pod/Catmandu::Exporter::Table) for an application of this module that can be
used to easily convert data to Markdown tables.

Similar table-generating modules include:

- [Text::Table::Tiny](https://metacpan.org/pod/Text::Table::Tiny)
- [Text::TabularDisplay](https://metacpan.org/pod/Text::TabularDisplay)
- [Text::SimpleTable](https://metacpan.org/pod/Text::SimpleTable)
- [Text::Table](https://metacpan.org/pod/Text::Table)
- [Text::ANSITable](https://metacpan.org/pod/Text::ANSITable)
- [Text::ASCIITable](https://metacpan.org/pod/Text::ASCIITable)
- [Text::UnicodeBox::Table](https://metacpan.org/pod/Text::UnicodeBox::Table)
- [Table::Simple](https://metacpan.org/pod/Table::Simple)
- [Text::SimpleTable](https://metacpan.org/pod/Text::SimpleTable)
- [Text::SimpleTable::AutoWidth](https://metacpan.org/pod/Text::SimpleTable::AutoWidth)

# AUTHOR

Jakob Voß <jakob.voss@gbv.de>

# COPYRIGHT AND LICENSE

Copyright 2014- Jakob Voß

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# POD ERRORS

Hey! **The above document had some coding errors, which are explained below:**

- Around line 108:

    Non-ASCII character seen before =encoding in 'Voß'. Assuming ISO8859-1
