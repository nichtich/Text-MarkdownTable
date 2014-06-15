# NAME

Catmandu::Exporter::Table - ASCII/Markdown table exporter

# SYNOPSIS

    echo '{"one":"my","two":"table"} {"one":"is","two":"nice"}]' | \ 
    catmandu convert JSON --multiline 1 to Table
    | one | two   |
    |-----|-------|
    | my  | table |
    | is  | nice  |

# DESCRIPTION

This [Catmandu::Exporter](https://metacpan.org/pod/Catmandu::Exporter) exports data in tabular form, formatted in
MultiMarkdown syntax. The resulting format can be used for instance to display
CSV data or to include data tables in Markdown files.

# CONFIGURATION

- fields

    Array, hash reference, or comma-separated list of fields/columns.

- columns

    Column names. By default field names are used.

- widths

    Column widths. Automatically set.

# CONTRIBUTING

This module is managed it a git repository hosted at
[https://github.com/nichtich/Catmandu-Exporter-Table](https://github.com/nichtich/Catmandu-Exporter-Table). Bug reports, feature
requests, and pull requests are welcome. The distribution is packages with
[Dist::Milla](https://metacpan.org/pod/Dist::Milla).

# SEE ALSO

Parts of this module have been copied from [Catmandu::Exporter::CSV](https://metacpan.org/pod/Catmandu::Exporter::CSV).
