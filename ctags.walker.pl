#!/usr/bin/perl

use ExtractFnc;
use ExtractVars;

 open(src, '<', $ARGV[0])
  or die "ctags file '$ARGV[0]' $!";
  
while( <src> )
{
    my $str = $_;
    next if( $str =~ /^!/ ); # skip comments
    #print $str;
    if( $str =~ /^([^\t]+)\t+([^\t]+)\t+([^\t]+)\t+([^\t]+)/ )
    {
        $obj   = $1;
        $file  = $2;
        $regex = $3;
        $type  = $4;
        $type  =~ s/[\r\n]//g;
        #print "$file $type $obj $regex\n";
        
        if( $type eq 'f' )
        {
            ExtractFnc::extract($file, $regex);
        }
        elsif( $type eq 'v' )
        {
            ExtractVars::extract($file, $regex);
        }
    }
}
  
