#!/usr/bin/perl




unless ($#ARGV >=0) 
{print " program formfactor used to calculate the formfactor for a ion described in single ion paramater file *.*";
 print " usage: formfactor  *.*  \n *.* .. filenname\n";
 exit 0;}
 
  foreach (@ARGV)
  {
   $file=$_;
   print "<".$file;
   open (Fin, $file);
   while($line=<Fin>)
     {
       if ($line=~/^\s*#/) {}
       else{
           if($line=~/^.*IONTYPE\s*=/) {($IONTYPE)=($line=~m|IONTYPE\s*=\s*(.+)|);} 
           if($line=~/^.*FFj0A\s*=/) {($FFj0A)=($line=~m|FFj0A\s*=\s*([\d.eEdD\Q-\E\Q+\E]+)|);} 
           if($line=~/^.*FFj0a\s*=/) {($FFj0a)=($line=~m|FFj0a\s*=\s*([\d.eEdD\Q-\E\Q+\E]+)|);} 
           if($line=~/^.*FFj0B\s*=/) {($FFj0B)=($line=~m|FFj0B\s*=\s*([\d.eEdD\Q-\E\Q+\E]+)|);} 
           if($line=~/^.*FFj0b\s*=/) {($FFj0b)=($line=~m|FFj0b\s*=\s*([\d.eEdD\Q-\E\Q+\E]+)|);} 
           if($line=~/^.*FFj0C\s*=/) {($FFj0C)=($line=~m|FFj0C\s*=\s*([\d.eEdD\Q-\E\Q+\E]+)|);} 
           if($line=~/^.*FFj0c\s*=/) {($FFj0c)=($line=~m|FFj0c\s*=\s*([\d.eEdD\Q-\E\Q+\E]+)|);} 
           if($line=~/^.*FFj0D\s*=/) {($FFj0D)=($line=~m|FFj0D\s*=\s*([\d.eEdD\Q-\E\Q+\E]+)|);} 
           if($line=~/^.*FFj2A\s*=/) {($FFj2A)=($line=~m|FFj2A\s*=\s*([\d.eEdD\Q-\E\Q+\E]+)|);} 
           if($line=~/^.*FFj2a\s*=/) {($FFj2a)=($line=~m|FFj2a\s*=\s*([\d.eEdD\Q-\E\Q+\E]+)|);} 
           if($line=~/^.*FFj2B\s*=/) {($FFj2B)=($line=~m|FFj2B\s*=\s*([\d.eEdD\Q-\E\Q+\E]+)|);} 
           if($line=~/^.*FFj2b\s*=/) {($FFj2b)=($line=~m|FFj2b\s*=\s*([\d.eEdD\Q-\E\Q+\E]+)|);} 
           if($line=~/^.*FFj2C\s*=/) {($FFj2C)=($line=~m|FFj2C\s*=\s*([\d.eEdD\Q-\E\Q+\E]+)|);} 
           if($line=~/^.*FFj2c\s*=/) {($FFj2c)=($line=~m|FFj2c\s*=\s*([\d.eEdD\Q-\E\Q+\E]+)|);} 
           if($line=~/^.*FFj2D\s*=/) {($FFj2D)=($line=~m|FFj2D\s*=\s*([\d.eEdD\Q-\E\Q+\E]+)|);} 
           }
      }
      close Fin;
   print ">\n";
   print "IONTYPE=$IONTYPE\n";
   if ($IONTYPE=~/.*Pr3+/){$gJ=0.8;}
   if ($IONTYPE=~/.*Yb3+/){$gJ=1.143;}
   if ($gJ==0) {print "ion not recognized\n exiting ...\n"; exit(1);}
   print "|Q|(1/A)  F(Q) |F(Q)|^2\n";
  for($Q=0;$Q<10;$Q+=0.1)
   {$s=$Q/4/3.1415;
   $j0 = $FFj0A * exp(-$FFj0a * $s * $s) + $FFj0B  * exp(-$FFj0b * $s * $s);
   $j0 = $j0 + $FFj0C * exp(-$FFj0c * $s * $s) + $FFj0D;
     
   $j2 = $FFj2A*$s*$s*exp(-$FFj2a*$s*$s)+$FFj2B*$s*$s*exp(-$FFj2b*$s*$s);
   $j2 = $j2 + $FFj2C * $s * $s * exp(-$FFj2c * $s * $s) + $s * $s * $FFj2D;
   $F=$j0 + $j2 * (2 / $gJ - 1);
   $FF=$F*$F;
   print "$Q $F $FF\n";
   }
  }