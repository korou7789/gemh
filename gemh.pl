#!/usr/bin/env perl

my $in_pre = 0;
my $in_list = 0;

while (<STDIN>) {
    chomp;
    s/\r$//;
    if ($in_pre) {
	if (/^```/) {
	    print "</pre>\n";
	    $in_pre = 0;
	} else {
	    print "$_\n";
	}
	next;
    }
    if ($in_list && !/^\* .*$/) {
	print "</ul>\n";
	$in_list = 0;
    }

    if (/^=>[ \t]*([^ \t]+)(?:[ \t]+(.*))?$/) {
	my $url = $1;
	my $label = $2 // "";
	$label = $url if $label eq "";
	print "<p><a href=\"$url\">$label</a></p>\n";
    } elsif(/^(#{1,3})[ \t]*(.*)$/) {
	my $level = length($1);
	print "<h$level>";
	print $2;
	print "</h$level>\n";
    } elsif (/^\* (.*)$/) {
	print "<ul>\n" unless $in_list;
	print "<li>$1</li>\n";
	$in_list = 1;
    } elsif (/^> *(.*)$/) {
	print "<blockquote>$1</blockquote>\n";
    } elsif (/^```/) {
	print "<pre>";
	$in_pre = 1;
    } else {
	print "<p>$_</p>\n";
    }
}

print "</pre>\n" if $in_pre;
print "</ul>\n" if $in_list;
