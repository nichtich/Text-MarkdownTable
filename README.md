# NAME

Catmandu::Exporter::Table - ASCII/Markdown table exporter

# SYNOPSIS

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

# DESCRIPTION

This [Catmandu::Exporter](https://metacpan.org/pod/Catmandu::Exporter) exports data in tabular form, formatted in
MultiMarkdown syntax. The resulting format can be used for instance to display
CSV data or to include data tables in Markdown files. Newlines and vertical
bars in table cells are replaced by a space character and cell values can be
truncated.

# CONFIGURATION

- fields

    Array, hash reference, or comma-separated list of fields/columns.

- header

    Column names. By default field names are used.

- widths

    Column widths. By default column widths are calculated automatically to the
    width of the widest value. With custom width, large values may be truncated.

# METHODS

See [Catmandu::Exporter](https://metacpan.org/pod/Catmandu::Exporter), [Catmandu::Addable](https://metacpan.org/pod/Catmandu::Addable), [Catmandu::Fixable](https://metacpan.org/pod/Catmandu::Fixable),
[Catmandu::Counter](https://metacpan.org/pod/Catmandu::Counter), and [Catmandu::Logger](https://metacpan.org/pod/Catmandu::Logger) for a full list of methods.

# SEE ALSO

[Catmandu::Exporter::CSV](https://metacpan.org/pod/Catmandu::Exporter::CSV)
