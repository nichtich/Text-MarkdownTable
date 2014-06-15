use strict;
use warnings;
use Test::More;

BEGIN {
    use_ok 'Catmandu::Exporter::Table';
}
require_ok 'Catmandu::Exporter::Table';

my $got;

sub export_table(@) {
    my (%config) = @_;
    ${$config{file}} = "";
    my $data = delete $config{data};
    my $exporter = Catmandu::Exporter::Table->new(%config);
    isa_ok $exporter, 'Catmandu::Exporter::Table';
    $exporter->add($_) for @$data;
    $exporter->commit;
    is($exporter->count, scalar @$data, "Count ok");
}

export_table
    file => \$got,
    data => [{'a' => 'moose', b => '1'}, {'a' => 'pony', b => '2'}, {'a' => 'shrimp', b => '3'}];

my $table = <<TABLE;
| a      | b |
|--------|---|
| moose  | 1 |
| pony   | 2 |
| shrimp | 3 |
TABLE

is($got, $table, "MultiMarkdown format ok");
 
export_table
    file => \$got,
    fields => { a => 'Longname', x => 'X' },
    data => [
        { a => 'Hello', b => 'World' }
    ];

$table = <<TABLE;
| Longname | X |
|----------|---|
| Hello    |   |
TABLE
is $got, $table, 'custom column names as HASH';

note $got;

done_testing;
