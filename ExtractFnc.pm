##!/usr/bin/perl
package ExtractFnc;
use File::Basename;


sub extract
{
    my($filename, $regex) = @_;

 open(src, '<', $filename)
  or die "Could not open file '$filename' $!";

#fetch function func_name
$regex =~ /\s+([A-Za-z0-9_]+)\s*\(/g;
$func_name = $1;

# cleanup ctag regex:
$regex =~ s/[\^\$\"\;]//g;
$regex =~ s/\(/\\\(/g;
$regex =~ s/\)/\\\)/g; 

#print "// Filename: $filename regex: $regex function: $func_name\n";

$filename = basename $filename;

my %funchash;
my $body = "";
while( <src> )
{
    my $str = $_;

    if( eval("\$str =~ $regex") )
    {
        $body ="$body$str";
    }
    else
    {
        if( length($body) > 0 )
        {
            $body = "$body$str";

            my $open_bracket_count = $body =~ tr/\{//;
            my $close_bracket_count = $body =~ tr/\}//;

            if( $open_bracket_count == $close_bracket_count
                && $open_bracket_count > 0)
            {
            	$funchash{$func_name} = $body; 
                #open (int_point, ">../refact_out/$filename.$func_name.cpp");
                #print int_point $body;
                #close (int_point );
                $body = "";
            }
        }
    }
}

return %funchash;

}

# module initalization
1;

