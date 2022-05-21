#!/usr/bin/perl

use strict;
use warnings;

use File::Find;
use File::stat;
use Time::localtime;

my @files_changed;

find(\&wanted, ($ARGV[0]));
sub wanted {
  my $file = $File::Find::name;
  my $st = stat($file);

  if ( -T $file ) {
    print "$file\n";
    print ctime($st->ctime);
    print "\n";

    if ( /\.[tj]s(x|)$/g ) {
      my $content = read_file($file);

      if ($content =~ s/console\.log\((\"|\'|\`)( |)#filename/console.log($1$2$_)/g) {
        write_file($file, $content);
        push @files_changed, $file;
      }
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
    print "files changed:\n";
    print @files_changed;
    print "\n";
  } else {
    print "no files changed\n";
  }
}

1;
