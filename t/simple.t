use strict;
use warnings;
use Test::More;

BEGIN {
    use_ok 'Catmandu::Exporter::Table';
}
require_ok 'Catmandu::Exporter::Table';

my $file = "";
my $exporter = Catmandu::Exporter::Table->new(file => \$file);
 
isa_ok $exporter, 'Catmandu::Exporter::Table';
 
my $data = [{'a' => 'moose', b => '1'}, {'a' => 'pony', b => '2'}, {'a' => 'shrimp', b => '3'}];
$exporter->add($_) for @$data;
$exporter->commit;

my $table = <<TABLE;
| a      | b |
|--------|---|
| moose  | 1 |
| pony   | 2 |
| shrimp | 3 |
TABLE

#note $file;
is($file, $table, "MultiMarkdown format ok");
is($exporter->count,3, "Count ok");
 
done_testing;
