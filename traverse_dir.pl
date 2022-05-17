#!/usr/bin/perl

use strict;
use warnings;

use File::Find;

my @files_changed;

find(\&wanted, ($ARGV[0]));
sub wanted {
  my $file = $File::Find::name;

  if ( -T $file and /\.[tj]s(x|)$/g ) {
    my $content = read_file($file);

    if ($content =~ s/console\.log\((\"|\'|\`)( |)#filename/console.log($1$2$_)/g) {
      push @files_changed, $file;
    }
  }
}

sub read_file {
  local $/;
  my $filename = shift;

  open my $fh, '<:encoding(UTF-8)', $filename or die "can't open $filename: $!";
  return <$fh>;
}

{
  local $, = "\n";
  print @files_changed;
  print "\n";
}

1;
