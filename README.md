# NAME

Text::MarkdownTable - Write Markdown syntax tables from data

# SYNOPSIS

    my $table = Text::MarkdownTable->new;
    $table->add_row({one=>"my",two=>"table"});
    $table->add_row({one=>"is",two=>"nice"});
    $table->done;

    | one | two   |
    |-----|-------|
    | my  | table |
    | is  | nice  |

# DESCRIPTION

This module can be used to write data in tabular form, formatted in
MultiMarkdown syntax. The resulting format can be used for instance to display
CSV data or to include data tables in Markdown files. Newlines and vertical
bars in table cells are replaced by a space character and cell values can be
truncated.

# CONFIGURATION

- fields

    Array, hash reference, or comma-separated list of fields/columns.

- columns

    Column names. By default field names are used.

- widths

    Column widths. By default column widths are calculated automatically to the
    width of the widest value. With custom width, large values may be truncated.

# METHODS

- add

    Add a row as hash reference. Depending on the configuration rows are directly
    written or buffered.

- done

    Finish and write the table unless it has already been written.

# SEE ALSO

This module is a fork of [Catmandu::Exporter::Table](https://metacpan.org/pod/Catmandu::Exporter::Table). See
[Text::TabularDisplay](https://metacpan.org/pod/Text::TabularDisplay), [Text::SimpleTable](https://metacpan.org/pod/Text::SimpleTable), and [Text::Table](https://metacpan.org/pod/Text::Table),
[Text::ANSITable](https://metacpan.org/pod/Text::ANSITable), and [Text::ASCIITable](https://metacpan.org/pod/Text::ASCIITable) for similar modules.
