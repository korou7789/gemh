#!/usr/bin/env perl

sub escape_html {
    my $text = $_[0];
    return $text
        =~ s/&/&amp;/gr
        =~ s/</&lt;/gr
        =~ s/>/&gt;/gr
        =~ s/"/&quot;/gr
        =~ s/'/&#39;/gr;
}

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
	    print escape_html($_), "\n";
	}
	next;
    }
    if ($in_list && !/^\* /) {
	print "</ul>\n";
	$in_list = 0;
    }

    if (/^=>[ \t]*([^ \t]+)(?:[ \t]+(.*))?$/) {
	my $url = escape_html($1);
	my $label = escape_html($2 // "");
	$label = $url if $label eq "";
	print "<p><a href=\"$url\">$label</a></p>\n";
    } elsif(/^(#{1,3})[ \t]*(.*)$/) {
	my $level = length($1);
	print "<h$level>", escape_html($2), "</h$level>\n";
    } elsif (/^\* (.*)$/) {
	print "<ul>\n" unless $in_list;
	print "<li>", escape_html($1), "</li>\n";
	$in_list = 1;
    } elsif (/^> *(.*)$/) {
	print "<blockquote>", escape_html($1), "</blockquote>\n";
    } elsif (/^```/) {
	print "<pre>";
	$in_pre = 1;
    } else {
	print "<p>", escape_html($_), "</p>\n";
    }
}

print "</pre>\n" if $in_pre;
print "</ul>\n" if $in_list;
