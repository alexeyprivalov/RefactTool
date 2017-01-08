#!/usr/bin/perl

use ExtractFnc;
use ExtractVars;

my @file_array;
my @namespace_array;

open(src, '<', $ARGV[0])
	or die "ctags file '$ARGV[0]' $!";


open(file_target, '<', $ARGV[1]);
while(<file_target>)
{
	my $str = $_;
	if( $str =~ /^([^\t]+)\t+([^\t\r\n]+)/ )
	{
		@file_array=(@file_array,[$1,$2]);
	}
}

open(namespace_target, '<', $ARGV[2]);  
while(<namespace_target>)
{
	my $str = $_;
	if( $str =~ /^([^\t]+)\t+([^\t\r\n]+)/ )
	{
		@namespace_array=(@namespace_array,[$1,$2]);
	}
}

#
# Loading tag file
#
my %func_hash;
my %var_hash;
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
            %func_hash = ( %func_hash, ExtractFnc::extract($file, $regex));
            %func_decl_hash = (%func_decl_hash, ExtractFnc::extract_declaration($regex));
        }
        elsif( $type eq 'v' )
        {
            %var_hash = ( %var_hash, ExtractVars::extract($file, $regex));
        }
    }
}

#
# create structure file.h->namespace->extern variables array
#
my %file_header_hash = ();

	
	#
	# looking for assinged variables 
	#
while( my($var_name,$var_type) = each %var_hash)
{
	namespace_split($var_name,\%file_header_hash);
}

# create structure file.h->namespace->functions declaration array
#
while( my($func_name,$func_body) = each %func_hash)
{
	namespace_split($func_name,\%file_header_hash);
}

#
# create structure file.cpp->namespace->variables array
#

#
# create structure file.cpp->namespace->functions implementation array 
#
  
#
# create file tree
#
while ( my($filename, $namespace_hash_ref) = each %file_header_hash )
{
	open (file_implementation, ">../refact_out/$filename.cpp");
	open (file_declaration, ">../refact_out/$filename.h");
	
	my %namespace_obj_hash = %{$namespace_hash_ref};
	while( my($namespace_name, $obj_array_ref) = each %namespace_obj_hash )
	{
		print  file_implementation "namespace $namespace_name\n{\n";
		print  file_declaration "namespace $namespace_name\n{\n";
		my @obj_array = @{$obj_array_ref};
		foreach(@obj_array)
		{
			my $obj_name = $_;
			
			if( exists $var_hash{$obj_name})
			{
				my $var_type  = $var_hash{$obj_name};
				print "[$filename.h]	[$namespace_name]	[$var_type]	[$obj_name]\n";
				
				print file_declaration "extern $var_type $obj_name;\n";
				print file_implementation "$var_type $obj_name;\n";
			}
		}
	
		foreach(@obj_array)
		{
			my $obj_name = $_;
			
			if( exists $func_hash{$obj_name})
			{
				print "[$filename.h]	[$namespace_name]	[---]	[$obj_name]\n";
				
				print file_declaration "$func_decl_hash{$obj_name}\n";
				print file_implementation "$func_hash{$obj_name}\n";
			}
		}
	
		print  file_declaration "} //namespace $namespace_name\n";
		print  file_implementation "} //namespace $namespace_name\n";
		
	}

	close(file_declaration);
	close(file_implementation);
}

sub namespace_split
{
	my($var_name,$file_header_hash_ref) = @_;
	
	foreach(@file_array) 
	{
		my($file_obj_pattern,$file_name) = @{$_};
		
		my %namespace_var_hash = ();
		%namespace_var_hash = %{${$file_header_hash_ref}{$file_name}} 
			if( exists ${$file_header_hash_ref}{$file_name} );
	
	
	
		if( eval("\$var_name =~ $file_obj_pattern"))
		{
			# var found
			# looking for the namespace
			my $namespace_name = "";
			foreach( @namespace_array )
			{
				my($namespace_obj_pattern, $namespace_name_) = @{$_};
				if( eval("\$var_name =~ $namespace_obj_pattern"))
				{
					$namespace_name = $namespace_name_;
					last;
				}
			}

			# put variable into the  namespace
			$namespace_var_hash{$namespace_name} = []
				if( not(exists $namespace_var_hash{$namespace_name}));
			$namespace_var_hash{$namespace_name} = [ $var_name, @{$namespace_var_hash{$namespace_name}} ];
			
			${$file_header_hash_ref}{$file_name} = \%namespace_var_hash;
			last;
			

		}
		
	}
		
}
