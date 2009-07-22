#!/usr/bin/perl

#\begin{verbatim}



unless ($#ARGV >1) 

{print " program multc  used to multiply columnx with columny in data file, the result goes to coly\n";

 print " usage: multc colx coly  *.*   \n colx=columnx, coly=columny \n *.* .. filenname\n";

 exit 0;}

 

$colx=$ARGV[0];shift @ARGV;

$coly=$ARGV[0];shift @ARGV;



  foreach (@ARGV)

  {

   $file=$_;

   unless (open (Fin, $file)){die "\n error:unable to open $file\n";}   
   print "<".$file;

   open (Fout, ">range.out");

   while($line=<Fin>)

     {

       if ($line=~/^\s*#/) {print Fout $line;}

       else{$line=~s/D/E/g;@numbers=split(" ",$line);

           	  $i=0;$numbers[$coly-1]*=$numbers[$colx-1];

		  foreach (@numbers)

		  {++$i;print Fout $numbers[$i-1]." ";}     

            print Fout "\n";

           }

      }

      close Fin;

      close Fout;

       unless (rename "range.out",$file)

          {unless(open (Fout, ">$file"))     

      {die "\n error:unable to write to $file\n";}

      open (Fin, "range.out");

      while($line=<Fin>){ print Fout $line;}

      close Fin;

      close Fout;

      system "del range.out"; 

     }



   print ">\n";

   }



#\end{verbatim} 