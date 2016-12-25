##!/usr/bin/perl

package ExtractVars;
use File::Basename;

sub extract
{
    my($filename, $regex) = @_;
    
    
    $filename = basename $filename;

    # cleanup ctag regex:
    $regex =~ s/[\^\$\"]//g;
    $regex =~ s/\(/\\\(/g;
    $regex =~ s/\)/\\\)/g;
    
    $body = $regex;
    
    open (int_point, ">>out/$filename.variables.cpp");
    print int_point "$body\n";
    close (int_point );
    $body = "";
    
}

# module initalization
1;
