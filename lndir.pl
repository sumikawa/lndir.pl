#!/usr/local/bin/perl
use Getopt::Std;
use File::Basename;

getopts('f');
die "Usage: $0 ref-dirs.. new-dir\n" if ($#ARGV < 1);

my $newdir = pop(ARGV);
if (! -e "$newdir") {
    mkdir($newdir) || die "cannot mkdir $newdir\n";
}
foreach my $refdir (@ARGV) {
    if (-d "$refdir") {
	print "$refdir ... directory - recursive chack\n";
	lndir($refdir, $newdir);
	next;
    }
    lndir($refdir, $newdir . "/" . basename($refdir));
}
exit 0;

sub lndir {
    my ($refdir, $newdir) = @_;

    if (-f "$refdir") {
	if (-l "$newdir") {
	    unlink ($newdir) if ($opt_f == 1);
	}
	link ($refdir, $newdir) && print "$refdir ... linked to $newdir\n";
	return;
    }
    if (! -d "$refdir") {
	print "not a plain file - skipped\n";
	return;
    }

    $newdir .= "/" . basename($refdir);
    if (-l "$newdir") {
	unlink ($newdir) if ($opt_f == 1);
    }
    if (! -e "$newdir") {
	mkdir("$newdir") || die "cannot mkdir $newdir\n";
    }

    opendir(refdir, $refdir) || die "opendir() failure\n";
    my @all = sort grep !/^\.{1,2}$/, readdir(refdir); # get rid of "." and ".."
    closedir(refdir);

    foreach my $file (@all) {
	if (-d "$refdir/$file") {
	    print "$refdir/$file ... directory - recursive chack\n";
	    lndir("$refdir/$file", "$newdir");
	    next;
	}
	lndir("$refdir/$file", "$newdir/$file");
    }
}
