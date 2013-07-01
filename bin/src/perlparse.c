//#include<cstdio>
#include<stdio.h>
#include<stdlib.h>

#include "martin.h"
#include "myev.h"
#include "perlparse.h"

void PrintComplexMatrix(FILE * fout, char * name, ComplexMatrix & mat)
{fprintf(fout,"my $%s=new Math::Matrix (\n",name);
 for (int i=mat.Rlo();i<=mat.Rhi();++i){fprintf(fout,"[");
   for (int j=mat.Clo();j<=mat.Chi();++j){fprintf(fout,"%g %+g *i",real(mat(i,j)),imag(mat(i,j)));
                                     if(j<mat.Chi())fprintf(fout,",");}
                                   fprintf(fout,"]");if(i<mat.Rhi())fprintf(fout,",\n");
                                   }fprintf(fout,");\n");
}

int perlparse(char*sipffilename
              ,double ** numbers,char ** numbernames    // number 
              ,char **  strings,char ** stringnames    // string variables
              ,ComplexMatrix **  operators,char ** operatornames    // operators
              )
{FILE * fin,*fout; 
 char  command[MAXNOFCHARINLINE],perlfile[MAXNOFCHARINLINE],instr[MAXNOFCHARINLINE];

 fin=fopen(sipffilename,"rb");
 while(feof(fin)==0){if(fgets(instr,MAXNOFCHARINLINE,fin)!=NULL){if(strncmp(instr,"#!noperl",8)==0)
                     {fclose(fin);return myparse(sipffilename,numbers,numbernames,strings,stringnames,operators,operatornames);}
                    }}
  
 sprintf(perlfile,"results/_%s.pl",sipffilename);
 fout=fopen(perlfile,"w");
  // output header to perl file
  fprintf(fout,"#--- start of autogenerated prolog ---\n"
               "use lib $ENV{MCPHASE_DIR}.\"/bin\";"
               "use warnings;\n"
               "use Math::Complex;\n"
               "use Matrix;\n"
               "$Math::Matrix::Precision = 5;\n");
  // output initial values for variables to perl file
    for(int i=0;numbernames[i]!=NULL;++i)fprintf(fout,"my $%s=%g;\n",numbernames[i],(*numbers[i]));
    for(int i=0;stringnames[i]!=NULL;++i)fprintf(fout,"my $%s=\"%s\";\n",stringnames[i],strings[i]);
    for(int i=0;operatornames[i]!=NULL;++i)PrintComplexMatrix(fout,operatornames[i],(*operators[i]));

 fprintf(fout,"#---- end autogenerated prolog ----\n\n\n");
  // output sipffile to perl program
  fseek(fin,0,SEEK_SET);
  while(feof(fin)==0){if(fgets(instr,MAXNOFCHARINLINE,fin)!=NULL)fprintf(fout,instr);}
  fclose(fin);


  // output printing statements to perl program  
  fprintf(fout,"\n\n\n#--- start of autogenerated epilog ---\n");
  fprintf(fout,"open Fout, \">results/_%s.pl.out\";\n",sipffilename);
  for(int i=0;numbernames[i]!=NULL;++i)fprintf(fout,"print Fout \"%s=\".$%s.\"\\n\";\n",numbernames[i],numbernames[i]);
  for(int i=0;stringnames[i]!=NULL;++i)fprintf(fout,"print Fout \"%s=\".$%s.\"\\n\";\n",stringnames[i],stringnames[i]);
  for(int i=0;operatornames[i]!=NULL;++i)fprintf(fout,"print Fout \"%s=\\n\",$%s->as_blocks();\n",operatornames[i],operatornames[i]);
  fprintf(fout,"close Fout;\n");
  fprintf(fout,"#--- end of autogenerated epilog ---\n");

 fclose(fout);

// system call to perl
 sprintf(command,"perl results/_%s.pl\n",sipffilename);
  
if(system(command)){fprintf(stderr,"Error parsing sipffile through perl\n");return false; }

// read perl output and fill variables with values
 double dummy;
 sprintf(perlfile,"results/_%s.pl.out",sipffilename);
  fin=fopen(perlfile,"rb");
  while(feof(fin)==0){
   if(fgets(instr,MAXNOFCHARINLINE,fin)!=NULL)
   {for(int i=0;numbernames[i]!=NULL;++i)extract(instr,numbernames[i],(*numbers[i]));
    for(int i=0;stringnames[i]!=NULL;++i)extract(instr,stringnames[i],strings[i],(size_t)MAXNOFCHARINLINE);
    for(int i=0;operatornames[i]!=NULL;++i)if(extract(instr,operatornames[i],dummy)==0)
                                            {if(myReadComplexMatrix (fin, (*operators[i]))==false)
                                              {fprintf(stderr,"Error parsing sipffile through perl - reading matrix from output\n");return false; }
                                             }
    }
                     }
 fclose(fin); 

return true;
}


// this substitutes the perl parsing in order to avoid big memory problems
// however the syntax of the commands to parse must be much simpler ...
int myparse(char*sipffilename
              ,double ** numbers,char ** numbernames    // number 
              ,char **  strings,char ** stringnames    // string variables
              ,ComplexMatrix **  operators,char ** operatornames    // operators
              )
{FILE * fin; 
 char  instr[MAXNOFCHARINLINE];
 printf("# using noperl parsing\n");
 fin=fopen(sipffilename,"rb");
  while(feof(fin)==0)
  {if(fgets(instr,MAXNOFCHARINLINE,fin)!=NULL)
   {if(instr[strspn(instr," \t")]!='#'&&strlen(instr)>3){
      // do something it is a command line
        // get first variable index
        char *token,*t1;int i1=-1;
        if(instr[0]!='$')return false; // must start with $ sign
        for(int i=0;operatornames[i]!=NULL;++i)if ((token = strstr (instr, operatornames[i]))==instr+1)
                                               {t1=token+strlen(operatornames[i]);if(t1[0]=='='||t1[0]=='+')i1=i;} 
        if (i1==-1)return false; // check if a parameter and a = after it is found - if not return false
        int pe=0;
        if(t1[0]=='+'&&t1[1]=='='){++t1;pe=1;}else if (t1[0]=='+')return false;
        t1++; // now i1 is the index of the ComplexMatrix to be assigned ...
       // now read the phrase after the = sign
       double cst=1.0;
       if(t1[0]!='$'){//read cst to be multiplied
                      cst= strtod (t1, NULL);
                      if((t1=strstr(t1,"*"))==NULL)return false;
                      ++t1;
                     }
       // check if $ ... i.e. variable name
        if(t1[0]=='$')
          {// lets look which matrix is to be assigned
           int i2=-1;char * t2=t1;
           for(int i=0;operatornames[i]!=NULL;++i)if ((token = strstr (t1, operatornames[i]))==t1+1)
                                               {t2=token+strlen(operatornames[i]);if(t2[0]==';')i2=i;} 
           if (i2==-1)return false; // check if a parameter and a ; after it is found - if not return false
           if(pe){
           //  += assignment
            if(cst==1.0){(*operators[i1])+=(*operators[i2]);//printf("%i=%i\n",i1,i2);
                       } else {(*operators[i1])+=cst*(*operators[i2]);}
           }else{
           // = asssign
           if(cst==1.0){(*operators[i1])=(*operators[i2]);//printf("%i=%i\n",i1,i2);
                       } else {(*operators[i1])=cst*(*operators[i2]);}
           }

          } else{return false;} // constants other than matrix names are not yet implemented
   }}
  }
 fclose(fin);
 return true;
}
/* for test 
int main(int argc,char **argv)
{
//char sipffilename[]="test.sipf";
char numnam[]="alpha\0beta \0gamma\0";
double numbers[]={2.3,2.5,3.7};
char * numbernames[4];
for (int i=0;i<3;++i)numbernames[i]=numnam+6*i;numbernames[3]=NULL;

char * strings[3];char * stringnames[3];
char strnam[]="IONTYPE\0TITLE\0";   
stringnames[0]=strnam;stringnames[1]=strnam+8;stringnames[2]=NULL;
strings[0]=new char [MAXNOFCHARINLINE];
strings[1]=new char [MAXNOFCHARINLINE];
strcpy(strings[0],"Ce3p");
strcpy(strings[1],"Tomomi");

ComplexMatrix * operators[3];char * operatornames[3];
char opnam[]="I1 \0I2 \0";   
for (int i=0;i<2;++i)operatornames[i]=opnam+4*i;operatornames[2]=NULL;
operators[0]=new ComplexMatrix(1,3,1,3);(*operators[0])=0;
operators[1]=new ComplexMatrix(1,3,1,3);(*operators[1])=0;

if(perlparse(argv[1],numbers,numbernames,strings,stringnames,operators,operatornames)==false){printf("Error perl parsing sipf file\n");}

// print out modified number set
printf("%s = %g\n",numbernames[0],numbers[0]);
printf("%s = %g\n",numbernames[1],numbers[1]);
printf("%s = %g\n",numbernames[2],numbers[2]);

printf("%s = %s\n",stringnames[0],strings[0]);
printf("%s = %s\n",stringnames[1],strings[1]);

printf("%s =\n",operatornames[0]);myPrintComplexMatrix(stdout,(*operators[0]));
printf("%s =\n",operatornames[1]);myPrintComplexMatrix(stdout,(*operators[1]));
}

*/