#!/usr/bin/env perl
use strict;

print "/* WARNING: THIS FILE IS GENERATED - DO NOT PATCH!\n";
print "   It's not enough alone in any case, because the defaults may be\n";
print "   coming from the individual *-settings.c in some situations. If you\n";
print "   wish to modify defaults, change the other *-settings.c files and\n";
print "   just delete this file. This file will be automatically regenerated\n";
print "   by make. (This file is distributed in the tarball only because some\n";
print "   systems might not have Perl installed.) */\n";
print '#include "lib.h"'."\n";
print '#include "array.h"'."\n";
print '#include "str.h"'."\n";
print '#include "ipwd.h"'."\n";
print '#include "var-expand.h"'."\n";
print '#include "file-lock.h"'."\n";
print '#include "fsync-mode.h"'."\n";
print '#include "hash-format.h"'."\n";
print '#include "net.h"'."\n";
print '#include "unichar.h"'."\n";
print '#include "hash-method.h"'."\n";
print '#include "settings.h"'."\n";
print '#include "settings-parser.h"'."\n";
print '#include "message-header-parser.h"'."\n";
print '#include "imap-urlauth-worker-common.h"'."\n";
print '#include "all-settings.h"'."\n";
print '#include <unistd.h>'."\n";
print '#define CONFIG_BINARY'."\n";

my @services = ();
my %service_defaults = {};
my @service_ifdefs = ();
my %parsers = {};

my $linked_file = 0;
foreach my $file (@ARGV) {
  if ($file eq "--") {
    $linked_file = 1;
    next;
  }
  my $f;
  open($f, $file) || die "Can't open $file: $@";
  
  my $state = 0;
  my $file_contents = "";
  my $externs = "";
  my $code = "";
  my %funcs;
  my $cur_name = "";
  my $ifdef = "";
  my $state_ifdef = 0;
  
  while (<$f>) {
    my $write = 0;
    if ($state == 0) {
      if (/struct .*_settings \{/ ||
	  /struct setting_define.*\{/ ||
	  /struct .*_default_settings = \{/) {
	$state++;
      } elsif (/^struct service_settings (.*) = \{/) {
	$state++;
	if ($ifdef eq "") {
	  $state_ifdef = 0;
	} else {
	  $_ = $ifdef."\n".$_;
	  $state_ifdef = 1;
	}
	push @services, $1;
	push @service_ifdefs, $ifdef;
      } elsif (/^const struct setting_keyvalue (.*_defaults)\[\] = \{/) {
        $service_defaults{$1} = 1;
        $state++;
      } elsif (/^(static )?const struct setting_parser_info (.*) = \{/) {
	$cur_name = $2;
	if (/^const/ && $cur_name !~ /^\*/) {
	  $parsers{$cur_name} = 1;
	  if ($linked_file) {
	    $externs .= "extern const struct setting_parser_info $cur_name;\n";
	  }
	}
	$state++ if ($cur_name !~ /^\*default_/);
      } elsif (/^extern const struct setting_parser_info (.*);/) {
	$parsers{$1} = 1;
	$externs .= "extern const struct setting_parser_info $1;\n";
      } elsif (/\/\* <settings checks> \*\//) {
	$state = 4;
	$code .= $_;
      }
      
      if (/(^#ifdef .*)$/ || /^(#if .*)$/) {
	$ifdef = $1;
      } else {
	$ifdef = "";
      }
      
      if (/#define.*DEF/ || /^#undef.*DEF/ || /ARRAY_DEFINE_TYPE.*_settings/) {
	$write = 1;
	$state = 2 if (/\\$/);
      }
    } elsif ($state == 2) {
      $write = 1;
      $state = 0 if (!/\\$/);
    } elsif ($state == 4) {
      $code .= $_;
      $state = 0 if (/\/\* <\/settings checks> \*\//);
    }
    
    if ($state == 1 || $state == 3) {
      if ($state == 1 && $cur_name ne "") {
	if (/\.parent = /) {
	  delete($parsers{$cur_name});
	}
	if (/DEFLIST.*".*",(.*)$/) {
	  my $value = $1;
	  if ($value =~ /.*&(.*)\)/) {
	    $parsers{$1} = 0;
	    $externs .= "extern const struct setting_parser_info $1;\n";
	  } else {
	    $state = 3;
	  }
	}
      } elsif ($state == 3) {
	if (/.*&(.*)\)/) {
	  $parsers{$1} = 0;
	}        
      }
      
      s/^static const (struct master_settings master_default_settings)/$1/;

      $write = 1;
      if (/};/) {
	$state = 0;
	$cur_name = "";
	if ($state_ifdef) {
	  $_ .= "#endif\n";
	  $state_ifdef = 0;
	}
      }
    }
  
    $file_contents .= $_ if ($write);
  }
  
  print "/* $file */\n";
  print $externs;
  if (!$linked_file) {
    print $code;
    print $file_contents;
  }

  close $f;
}

sub service_name {
  $_ = $_[0];
  return $1 if (/^(.*)_service_settings$/);
  die "unexpected service name $_";
}
print "static const struct config_service config_default_services[] = {\n";
@services = sort { service_name($a) cmp service_name($b) } @services;
for (my $i = 0; $i < scalar(@services); $i++) {
  my $ifdef = $service_ifdefs[$i];
  print "$ifdef\n" if ($ifdef ne "");
  my $defaults = "NULL";
  if (defined($service_defaults{$services[$i]."_defaults"})) {
    $defaults = $services[$i]."_defaults";
  }
  print "\t{ &".$services[$i].", $defaults },\n";
  print "#endif\n" if ($ifdef ne "");
}
print "\t{ NULL, NULL }\n";
print "};\n";

print "const struct setting_parser_info *all_default_roots[] = {\n";
foreach my $name (sort(keys %parsers)) {
  my $module = $parsers{$name};
  next if (!$module);

  print "\t&".$name.", \n";
}
print "\tNULL\n";
print "};\n";
print "const struct setting_parser_info *const *all_roots = all_default_roots;\n";
print "const struct config_service *config_all_services = config_default_services;\n";
