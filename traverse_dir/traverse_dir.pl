#!/usr/bin/perl

# Replaces "#filename" string in
# "console.log('#filename" javascript statement
# on filename, where this statement reside.
# Usage: perl ./traverse_dir {directory}
# If dirrectory is ommited, cwd is used
# 
# Script can handle different brace types: ', ", `
# It does not follow symlinks
# It does not traverse hidden directories i.e.
# started with .

use strict;
use warnings;

use File::Find;
use Cwd qw(abs_path getcwd);

my @files_changed;
my $files_processed = 0;

find(\&wanted, (abs_path($ARGV[0]) || getcwd()));
sub wanted {
  my $file = $File::Find::name;

  if ( -T $file and $file =~ /\.[tj]s(x|)$/g and not $file =~/^\./g ) {
    $files_processed += 1;
    my $content = read_file($file);

    if ($content =~ s/console\.log\((\"|\'|\`)( |)#filename/console.log($1$2$_/g) {
      write_file($file, $content);
      push @files_changed, $file;
    }
  }
}

sub write_file {
  local $/;
  my $filename = shift;
  my $content = shift;

  open my $fh, '>', $filename or die "can't open $filename for writing: $!";
  print $fh $content;
}

sub read_file {
  local $/;
  my $filename = shift;

  open my $fh, '<:encoding(UTF-8)', $filename or die "can't open $filename for reading: $!";
  return <$fh>;
}

{
  local $, = "\n";
  if (@files_changed) {
    print "files processed: $files_processed\n";
    print "files changed:\n";
    print @files_changed;
    print "\n";
  } else {
    print "files processed: $files_processed\n";
    print "no files changed\n";
  }
}

1;
