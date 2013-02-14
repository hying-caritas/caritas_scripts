#!/usr/bin/perl -w

use strict;
use warnings;

use File::Path;
use IPC::Open2;

my $parallel = 4;
my $err = 0;
my $user_agent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; zh_CN; rv:1.8.1.18) Gecko/20081029 Firefox/2.0.0.18";

END {
    printf("Errors: $err\n");
}

#$ENV{"http_proxy"} = "http://proxy_url:port";

#
# バージョン取得
#

my $gmver = "";
my $tmpfile = "tmp.txt";
system("wget --timeout=10 --tries=12 -q -O $tmpfile "
    ."-U \"$user_agent\" "
    ."http://map.google.com/");
if(-f $tmpfile) {
    open(IN, $tmpfile);
    while(<IN>){
        if(m#http://mt\d\.google\.com/vt/lyrs=m\@(\d+)#) {
            $gmver = $1;
            last;
        }
    }
    close(IN);
    unlink($tmpfile);
}

if($gmver ne ""){
    print "Google Maps version is w2.$gmver\n";
}else{
    print "Google Maps version is unknown\n";
    exit;
}

#
# 地図のダウンロード
#
sub down_map
{
    my($zoom, $x, $y) = @_;
    my $zoom_0 = $zoom;
    my $zoom_1 = $zoom;
    my $x_0 = $x;
    my $x_1 = $x;
    my $y_0 = $y;
    my $y_1 = $y;
    my @imgpath;
    $zoom_0 =~ s/:.*//;
    $zoom_1 =~ s/.*://;
    $x_0 =~ s/:.*//;
    $x_1 =~ s/.*://;
    $y_0 =~ s/:.*//;
    $y_1 =~ s/.*://;

    my $thread = 0;
    my $skipping = "";
    my $target_url;
    my @tpid;
    for (my $i=0; $i<$parallel; $i++) {
        $tpid[$i] = -1;
        $imgpath[$i] = "";
    }

    for ($zoom=$zoom_0; $zoom>=$zoom_1; $zoom--) {
        my $zdepth = $zoom_0 - $zoom;
        for ($x=$x_0*2**$zdepth; $x<=($x_1+1)*2**$zdepth-1; $x++) {
            for ($y=$y_0*2**$zdepth; $y<=($y_1+1)*2**$zdepth-1; $y++) {
                my $zstr = sprintf("%02d", $zoom);
                my $xstr = sprintf("%010d", $x);
                my $ystr = sprintf("%010d", $y);

                my $imgpath = $zstr;
                for (my $i=0; $i<10; $i++) {
                    $imgpath .= "/" . substr($xstr,$i,1) . substr($ystr,$i,1);
                }
                $imgpath .= ".png";

                my $imgdir = $imgpath;
                $imgdir =~ s/\/[^\/]*$//;
                if (! -d $imgdir) {
                    mkpath($imgdir);
                }

                if (-e $imgpath) {
                    my $imgsize = (stat($imgpath))[7];
                    if ($imgsize == 0) {
                        unlink($imgpath);
                    }
                }

                if (! -e $imgpath) {
		    &wait_check($tpid[$thread], $imgpath[$thread]);

                    printf "Downloading z = %02d,  x = %010d, y = %010d from mt%d ...\n", $zoom, $x, $y, $thread%4;
                    my($chld_out, $chld_in);
                    $target_url = sprintf("http://mt%d.google.com/vt/lyrs=m\@$gmver&hl=zh_CN&x=$x&s=&y=$y&z=%d", $thread%4, (17 - ($zoom-2)));
                    $tpid[$thread] = open2($chld_out, $chld_in,
                        "wget",
                        "--referer=http://maps.google.com/",
                        "--timeout=10",
                        "--tries=12",
                        "-q",
                        "-O", "$imgpath",
                        "-U", $user_agent,
                        $target_url
                    );
                    $imgpath[$thread] = $imgpath;
                    select(undef, undef, undef, 0.3);
                    $thread = ($thread+1) % $parallel;
                    $skipping = "";
                } else {
                    if ($skipping eq "") {
                        print "Skipping existing files...\r";
                    }
                    $skipping = "y";
                }
            }
        }
    }
    for (my $i=0; $i<$parallel; $i++) {
	&wait_check($tpid[$i], $imgpath[$i]);
    }
}

sub wait_check()
{
    my ($pid, $file) = @_;

    if($pid > 0){
	waitpid $pid, 0;
	if ($? > 0 || (stat($file))[7] == 0) {
	    printf("Error at $file\n");
	    unlink($file);
	    $err++;
	}
    }
}


#
# Google Mapsの地図画像のダウンロード
#
# down_map(zoom, x, y);
#     zoom: 拡大率（gm_liteの,キーで確認可能、0-19）
#     x:    X値（gm_liteの!キーで確認可能）
#     y:    Y値（gm_liteの!キーで確認可能）
#

# 全世界
#down_map("19:14",   "0",        "0");

down_map("9:3",     "855:859",  "416:420");

# 日本
#down_map("13:7",    "57",       "22");
#down_map("13:7",    "56:57",    "23:24");
#down_map("13:7",    "55:57",    "25");
#down_map("13:7",    "55",       "26");

# 東京
#down_map("9:3",     "907:909",  "402:403");
