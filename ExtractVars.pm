##!/usr/bin/perl

package ExtractVars;
use File::Basename;


sub extract
{
    my($filename, $regex) = @_;
    
    my %varhash;
    
    
    $filename = basename $filename;

    # cleanup ctag regex:
    $regex =~ s/[\^\$\"]//g;
    $regex =~ s/\(/\\\(/g;
    $regex =~ s/\)/\\\)/g;
    
    $regex =~ /([A-Za-z0-9_]+)\s+([A-Za-z0-9_]+);/g;
    $var = $2;
    $type = $1;
    
    $body = $regex;
    
    #open (int_point, ">>../refact_out/$filename.variables.cpp");
    #print int_point "$body\n";
    #close (int_point );
    $body = "";
    
    $varhash{$var} = $type;
    
    return %varhash;
}

# module initalization
1;
