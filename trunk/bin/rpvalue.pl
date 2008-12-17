#!/usr/bin/perl
#\begin{verbatim}

unless ($#ARGV >1) 
{print " program rpvalue  used to calculate the rpvalue from 2 columns in a file\n";
 print " the rpvalue is defined as\n 100*[sum_{allpoints} abs(col2-col1)]/[sum_{allpoints}abs(col1)]\n";
 print " usage: rpvalue col1 col2  *.*   \n col=columns \n *.* .. filenname\n";
 exit 0;}
 
$col1=$ARGV[0];shift @ARGV;
$col2=$ARGV[0];shift @ARGV;

  foreach (@ARGV)
  {$nofpoints=0;$rpvalue=0;
   $file=$_;
   print "<".$file;
   open (Fin, $file);
   while($line=<Fin>)
     {
       if ($line=~/^\s*#/) {print Fout $line;}
       else{$line=~s/D/E/g;@numbers=split(" ",$line);
            $rpvalue+=abs($numbers[$col1-1]-$numbers[$col2-1]);
            $nofpoints+=abs($numbers[$col1-1]);
           }
     } 
      $rpvalue/=$nofpoints/100;
      print "rpvalue=".$rpvalue;
      close Fin;
   print ">\n";
   }

#\end{verbatim} 