#!/usr/bin/perl
use Getopt::Long;
#use Math::ElFun;
use PDL;
use PDL::Slatec;
use Switch;
use File::Copy;
$fileout="./results/mcdiffsummed.out";
@AARGV=@ARGV;
GetOptions("help"=>\$helpflag);
usage() if $helpflag;


$numbersold[6]=0;
$numbersold[7]=0;
$numbersold[8]=0;
$numbersold[11]=0;
unless (open(Fin,"./results/mcdiff.out")){ die "Error program sum_mcdiff_out: file  ./results/mcdiff.out not found\n";}
open(Fout,">".$fileout);
while($line=<Fin>)
{if ($line=~/^\s*#/){print Fout $line;}
 else
 { $line=~s/D/E/g; @numbers=split(" ",$line);
if($numbers[12]<0){
$numbersold[6]+=$numbers[6];
$numbersold[7]+=$numbers[7];
$numbersold[8]+=$numbers[8];
$numbersold[11]+=$numbers[11];
print Fout sprintf("%6.3f %6.3f %6.3f \n",
                    $numbers[0],
                    $numbers[1],
                    $numbers[2]);
}
else
{$numbers[6]+=$numbersold[6];
$numbers[7]+=$numbersold[7];
$numbers[8]+=$numbersold[8];
$numbers[11]+=$numbersold[11];
print Fout sprintf("%6.3f %6.3f %6.3f %7.4f %7.4f %7.3f %8.4f %5.4E %8.4f %8.4f %8.4f %5.4E %8.4f %8.4f\n",
                    $numbers[0],
                    $numbers[1],
                    $numbers[2],
                    $numbers[3],
                    $numbers[4],
                    $numbers[5],
                    $numbers[6],
                    $numbers[7],
                    $numbers[8],
                    $numbers[9],
                    $numbers[10],
                    $numbers[11],
                    $numbers[12],
                    $numbers[13]);
$numbersold[6]=0;
$numbersold[7]=0;
$numbersold[8]=0;
$numbersold[11]=0;

}
 }
}

print STDERR << "EOF";
 all calculated reflections with Iobs=-1 have been summed

 and stored in output file $fileout

EOF
exit;
sub usage() {

  print STDERR << "EOF";

    sum_mcdiff_out: program to sum all calculated intensities in mcdiff.out
                    which have been summed from experiment

    usage: sum_mcdiff_out -h
           sum_mcdiff_out

     -h           : this (help) message

    output files:

    $fileout

EOF

  exit;

}