use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Text::MarkdownTable'; }
require_ok 'Text::MarkdownTable';

my ($got, $expect);

sub table(@) {
    my (%config) = @_;
    $got = "";
    my $data = delete $config{data};
    my $table = Text::MarkdownTable->new(%config, file => \$got);
    isa_ok $table, 'Text::MarkdownTable';
    $table->add($_) for @$data;
    $table->done;
}

table data => [{'a' => 'moose', b => '1'}, 
               {'a' => "p\nony", b => '2'}, 
               {'a' => 'shr|mp', b => '3'}];

$expect = <<TABLE;
| a      | b |
|--------|---|
| moose  | 1 |
| p ony  | 2 |
| shr mp | 3 |
TABLE

is $got, $expect, "MultiMarkdown format ok";
 

table data => [ { a => 'Hello', b => 'World' } ],
      fields => { a => 'Longname', x => 'X' };
$expect = <<TABLE;
| Longname | X |
|----------|---|
| Hello    |   |
TABLE
is $got, $expect, 'custom column names as HASH';


table data => [ { a => 'Hi', b => 'World', c => 'long value' } ],
      widths => '5,3,6';
$expect = <<TABLE;
| a     | b   | c      |
|-------|-----|--------|
| Hi    | Wor | lon... |
TABLE

is $got, $expect, 'custom column width / truncation';

done_testing;
