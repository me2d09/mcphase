#include "ionpars.hpp"
#include "martin.h"
#include <cstring>
// ionpars: class to load and store matrices for internal module cfield
#include "ionpars.h"

#define NOF_OLM_MATRICES 45
#define MAXNOFCHARINLINE 1024
#define K_B  0.0862
#define SMALL 1e-6   //!!! must match SMALL in mcdisp.c and ionpars.cpp !!!
                     // because it is used to decide wether for small transition
		     // energy the matrix Mijkl contains wn-wn' or wn/kT

 ionpars::ionpars (const ionpars & p) //copy constructor
 {J=p.J;
  Ja=p.Ja; Jb=p.Jb; Jc=p.Jc;Hcf=p.Hcf;
  Jaa=p.Jaa; Jbb=p.Jbb; Jcc=p.Jcc;
  gJ=p.gJ;
  alpha=p.alpha;beta=p.beta;gamma=p.gamma;
  r2=p.r2;r4=p.r4;r6=p.r6;
  Blm=p.Blm; // vector of crystal field parameters
  
   int i;
   Olm = new Matrix * [1+NOF_OLM_MATRICES];  // define array of pointers to our Olm matrices
   OOlm= new ComplexMatrix * [1+NOF_OLM_MATRICES]; 

 for(i=1;i<=NOF_OLM_MATRICES;++i)
 { Olm [i]= new Matrix(1,(*p.Olm[i]).Rhi(),1,(*p.Olm[i]).Chi()); 
 // define first matrix 
   OOlm [i] = new ComplexMatrix(1,(*p.OOlm[i]).Rhi(),1,(*p.OOlm[i]).Chi()); 
   (*Olm[i])=(*p.Olm[i]);
   (*OOlm[i])=(*p.OOlm[i]);
 }  

}
ionpars::ionpars (int dimj) // constructor from dimj
 {
  J=((double)dimj-1)/2;
  Ja=Matrix(1,dimj,1,dimj);
  Jb=Matrix(1,dimj,1,dimj);
  Jc=Matrix(1,dimj,1,dimj);
  Hcf=Matrix(1,dimj,1,dimj);
  Jaa=ComplexMatrix(1,dimj,1,dimj);
  Jbb=ComplexMatrix(1,dimj,1,dimj);
  Jcc=ComplexMatrix(1,dimj,1,dimj);

   Blm=Vector(1,45);Blm=0; // vector of crystal field parameters

   Olm = new Matrix * [1+NOF_OLM_MATRICES];  // define array of pointers to our Olm matrices
   OOlm= new ComplexMatrix * [1+NOF_OLM_MATRICES]; 


 int i;   
 for(i=1;i<=NOF_OLM_MATRICES;++i)
 { Olm [i]= new Matrix(1,dimj,1,dimj); 
 // define first matrix 
   OOlm [i] = new ComplexMatrix(1,dimj,1,dimj); 
 }  

}

 
ionpars::ionpars (char * iontype) // constructor from iontype (mind:no matrices filled with values !)
 {int dimj;
  getpar(iontype, &dimj, &alpha, &beta, &gamma, &gJ,&r2, &r4,&r6 );

  J=((double)dimj-1)/2;
  Ja=Matrix(1,dimj,1,dimj);
  Jb=Matrix(1,dimj,1,dimj);
  Jc=Matrix(1,dimj,1,dimj);
  Hcf=Matrix(1,dimj,1,dimj);
  Jaa=ComplexMatrix(1,dimj,1,dimj);
  Jbb=ComplexMatrix(1,dimj,1,dimj);
  Jcc=ComplexMatrix(1,dimj,1,dimj);

   Blm=Vector(1,45);Blm=0; // vector of crystal field parameters

   Olm = new Matrix * [1+NOF_OLM_MATRICES];  // define array of pointers to our Olm matrices
   OOlm= new ComplexMatrix * [1+NOF_OLM_MATRICES]; 


 int i;   
 for(i=1;i<=NOF_OLM_MATRICES;++i)
 { Olm [i]= new Matrix(1,dimj,1,dimj); 
 // define first matrix 
   OOlm [i] = new ComplexMatrix(1,dimj,1,dimj); 
 }  

}

ionpars::~ionpars(){
 int i;
 for (i=1;i<=NOF_OLM_MATRICES;++i)
 {delete Olm[i];delete OOlm[i];}
  delete []Olm;
  delete []OOlm;
 } //destructor

void ionpars::savBlm(FILE * outfile)
{
        fprintf(outfile,"B22S=%g\n",Blm(1));
        fprintf(outfile,"B21S=%g\n",Blm(2));
	fprintf(outfile,"B20=%g\n",Blm(3));
        fprintf(outfile,"B21=%g\n",Blm(4));
	fprintf(outfile,"B22=%g\n",Blm(5));
   
	fprintf(outfile,"B33S=%g\n",Blm(6));
	fprintf(outfile,"B32S=%g\n",Blm(7));
	fprintf(outfile,"B31S=%g\n",Blm(8));
	fprintf(outfile,"B30=%g\n",Blm(9));
   fprintf(outfile,"B31=%g\n",Blm(10));
   fprintf(outfile,"B32=%g\n",Blm(11));
   fprintf(outfile,"B32=%g\n",Blm(12));

   fprintf(outfile,"B44S=%g\n",Blm(13));
   fprintf(outfile,"B43S=%g\n",Blm(14));
   fprintf(outfile,"B42S=%g\n",Blm(15));
   fprintf(outfile,"B41S=%g\n",Blm(16));
   fprintf(outfile,"B40=%g\n",Blm(17));
   fprintf(outfile,"B41=%g\n",Blm(18));
   fprintf(outfile,"B42=%g\n",Blm(19));
   fprintf(outfile,"B43=%g\n",Blm(20));
   fprintf(outfile,"B44=%g\n",Blm(21));
  
   fprintf(outfile,"B55S=%g\n",Blm(22));
   fprintf(outfile,"B54S=%g\n",Blm(23));
   fprintf(outfile,"B53S=%g\n",Blm(24));
   fprintf(outfile,"B52S=%g\n",Blm(25));
   fprintf(outfile,"B51S=%g\n",Blm(26));
   fprintf(outfile,"B50=%g\n",Blm(27));
   fprintf(outfile,"B51=%g\n",Blm(28));
   fprintf(outfile,"B52=%g\n",Blm(29));
   fprintf(outfile,"B53=%g\n",Blm(30));
   fprintf(outfile,"B54=%g\n",Blm(31));
   fprintf(outfile,"B55=%g\n",Blm(32));
 
   fprintf(outfile,"B66S=%g\n",Blm(33));
   fprintf(outfile,"B65S=%g\n",Blm(34));
   fprintf(outfile,"B64S=%g\n",Blm(35));
   fprintf(outfile,"B63S=%g\n",Blm(36));
   fprintf(outfile,"B62S=%g\n",Blm(37));
   fprintf(outfile,"B61S=%g\n",Blm(38));
   fprintf(outfile,"B60=%g\n",Blm(39));
   fprintf(outfile,"B61=%g\n",Blm(40));
   fprintf(outfile,"B62=%g\n",Blm(41));
   fprintf(outfile,"B63=%g\n",Blm(42));
   fprintf(outfile,"B64=%g\n",Blm(43));
   fprintf(outfile,"B65=%g\n",Blm(44));
   fprintf(outfile,"B66=%g\n",Blm(45));

}

ionpars::ionpars(FILE * cf_file) 
//constructor with commands from file handle (filename of cf parameters etc)
{ 
static int pr=1;
//  FILE * tryfile;
  int dimj;complex<double> im(0,1);
  int i,j,l,dj=30; //30 ... maximum number of 2j+1
  char instr[MAXNOFCHARINLINE];
  char iontype[MAXNOFCHARINLINE];
  
   Blm=Vector(1,45);Blm=0; // vector of crystal field parameters

  // read in lines and get IONTYPE=  and CF parameters Blm
   while(feof(cf_file)==false)
  {fgets(instr, MAXNOFCHARINLINE, cf_file);
   if(instr[strspn(instr," \t")]!='#'){//unless the line is commented ...
        extract(instr,"IONTYPE",iontype,(size_t)MAXNOFCHARINLINE);
        extract(instr,"B22S",Blm(1));
        extract(instr,"B21S",Blm(2));
	extract(instr,"B20",Blm(3));
        extract(instr,"B21",Blm(4));
	extract(instr,"B22",Blm(5));
   
	extract(instr,"B33S",Blm(6));
	extract(instr,"B32S",Blm(7));
	extract(instr,"B31S",Blm(8));
	extract(instr,"B30",Blm(9));
   extract(instr,"B31",Blm(10));
   extract(instr,"B32",Blm(11));
   extract(instr,"B32",Blm(12));

   extract(instr,"B44S",Blm(13));
   extract(instr,"B43S",Blm(14));
   extract(instr,"B42S",Blm(15));
   extract(instr,"B41S",Blm(16));
   extract(instr,"B40",Blm(17));
   extract(instr,"B41",Blm(18));
   extract(instr,"B42",Blm(19));
   extract(instr,"B43",Blm(20));
   extract(instr,"B44",Blm(21));
  
   extract(instr,"B55S",Blm(22));
   extract(instr,"B54S",Blm(23));
   extract(instr,"B53S",Blm(24));
   extract(instr,"B52S",Blm(25));
   extract(instr,"B51S",Blm(26));
   extract(instr,"B50",Blm(27));
   extract(instr,"B51",Blm(28));
   extract(instr,"B52",Blm(29));
   extract(instr,"B53",Blm(30));
   extract(instr,"B54",Blm(31));
   extract(instr,"B55",Blm(32));
 
   extract(instr,"B66S",Blm(33));
   extract(instr,"B65S",Blm(34));
   extract(instr,"B64S",Blm(35));
   extract(instr,"B63S",Blm(36));
   extract(instr,"B62S",Blm(37));
   extract(instr,"B61S",Blm(38));
   extract(instr,"B60",Blm(39));
   extract(instr,"B61",Blm(40));
   extract(instr,"B62",Blm(41));
   extract(instr,"B63",Blm(42));
   extract(instr,"B64",Blm(43));
   extract(instr,"B65",Blm(44));
   extract(instr,"B66",Blm(45));

	}}
  
  
 // instr[strspn(instr," \t")]=='#');
  // take parameters from standard input file if no filename is given
 // if(instr[strspn(instr," \t")]=='#'||strlen(instr)-strspn(instr," \t")<=1)
 if(i==1){fprintf(stderr,"Error: no line in single ion property file contains IONTYPE field, e.g. IONTYPE=Nd3+\n");exit(EXIT_FAILURE);}
// get filename of parameter file out of first uncommented line in FILE * cf_file   
//  cf_filename=strtok(instr," \t\n");
  
  double ** hcfr,**hcfi,**Jxr,**Jxi,**Jyr,**Jyi,**Jzr,**Jzi;

  double ** mo22sr,**mo22si;
  double ** mo21sr,**mo21si;
  double ** mo20cr,**mo20ci;
  double ** mo21cr,**mo21ci;
  double ** mo22cr,**mo22ci;
  
  double ** mo33sr,**mo33si;
  double ** mo32sr,**mo32si;
  double ** mo31sr,**mo31si;
  double ** mo30cr,**mo30ci;
  double ** mo31cr,**mo31ci;
  double ** mo32cr,**mo32ci;
  double ** mo33cr,**mo33ci;

  double ** mo44sr,**mo44si;
  double ** mo43sr,**mo43si;
  double ** mo42sr,**mo42si;
  double ** mo41sr,**mo41si;
  double ** mo40cr,**mo40ci;
  double ** mo41cr,**mo41ci;
  double ** mo42cr,**mo42ci;
  double ** mo43cr,**mo43ci;
  double ** mo44cr,**mo44ci;
  
  double ** mo55sr,**mo55si;
  double ** mo54sr,**mo54si;
  double ** mo53sr,**mo53si;
  double ** mo52sr,**mo52si;
  double ** mo51sr,**mo51si;
  double ** mo50cr,**mo50ci;
  double ** mo51cr,**mo51ci;
  double ** mo52cr,**mo52ci;
  double ** mo53cr,**mo53ci;
  double ** mo54cr,**mo54ci;
  double ** mo55cr,**mo55ci;

  double ** mo66sr,**mo66si;
  double ** mo65sr,**mo65si;
  double ** mo64sr,**mo64si;
  double ** mo63sr,**mo63si;
  double ** mo62sr,**mo62si;
  double ** mo61sr,**mo61si;
  double ** mo60cr,**mo60ci;
  double ** mo61cr,**mo61ci;
  double ** mo62cr,**mo62ci;
  double ** mo63cr,**mo63ci;
  double ** mo64cr,**mo64ci;
  double ** mo65cr,**mo65ci;
  double ** mo66cr,**mo66ci;


    Jxr=new double*[dj+1];Jxi=new double*[dj+1];
    Jyr=new double*[dj+1];Jyi=new double*[dj+1];
    Jzr=new double*[dj+1];Jzi=new double*[dj+1];
    hcfr=new double*[dj+1];hcfi=new double*[dj+1];

  mo22sr=new double*[dj+1];mo22si=new double*[dj+1];
  mo21sr=new double*[dj+1];mo21si=new double*[dj+1];
  mo20cr=new double*[dj+1];mo20ci=new double*[dj+1];
  mo21cr=new double*[dj+1];mo21ci=new double*[dj+1];
  mo22cr=new double*[dj+1];mo22ci=new double*[dj+1];

  mo33sr=new double*[dj+1];mo33si=new double*[dj+1];
  mo32sr=new double*[dj+1];mo32si=new double*[dj+1];
  mo31sr=new double*[dj+1];mo31si=new double*[dj+1];
  mo30cr=new double*[dj+1];mo30ci=new double*[dj+1];
  mo31cr=new double*[dj+1];mo31ci=new double*[dj+1];
  mo32cr=new double*[dj+1];mo32ci=new double*[dj+1];
  mo33cr=new double*[dj+1];mo33ci=new double*[dj+1];

  mo44sr=new double*[dj+1];mo44si=new double*[dj+1];
  mo43sr=new double*[dj+1];mo43si=new double*[dj+1];
  mo42sr=new double*[dj+1];mo42si=new double*[dj+1];
  mo41sr=new double*[dj+1];mo41si=new double*[dj+1];
  mo40cr=new double*[dj+1];mo40ci=new double*[dj+1];
  mo41cr=new double*[dj+1];mo41ci=new double*[dj+1];
  mo42cr=new double*[dj+1];mo42ci=new double*[dj+1];
  mo43cr=new double*[dj+1];mo43ci=new double*[dj+1];
  mo44cr=new double*[dj+1];mo44ci=new double*[dj+1];

  mo55sr=new double*[dj+1];mo55si=new double*[dj+1];
  mo54sr=new double*[dj+1];mo54si=new double*[dj+1];
  mo53sr=new double*[dj+1];mo53si=new double*[dj+1];
  mo52sr=new double*[dj+1];mo52si=new double*[dj+1];
  mo51sr=new double*[dj+1];mo51si=new double*[dj+1];
  mo50cr=new double*[dj+1];mo50ci=new double*[dj+1];
  mo51cr=new double*[dj+1];mo51ci=new double*[dj+1];
  mo52cr=new double*[dj+1];mo52ci=new double*[dj+1];
  mo53cr=new double*[dj+1];mo53ci=new double*[dj+1];
  mo54cr=new double*[dj+1];mo54ci=new double*[dj+1];
  mo55cr=new double*[dj+1];mo55ci=new double*[dj+1];

  mo66sr=new double*[dj+1];mo66si=new double*[dj+1];
  mo65sr=new double*[dj+1];mo65si=new double*[dj+1];
  mo64sr=new double*[dj+1];mo64si=new double*[dj+1];
  mo63sr=new double*[dj+1];mo63si=new double*[dj+1];
  mo62sr=new double*[dj+1];mo62si=new double*[dj+1];
  mo61sr=new double*[dj+1];mo61si=new double*[dj+1];
  mo60cr=new double*[dj+1];mo60ci=new double*[dj+1];
  mo61cr=new double*[dj+1];mo61ci=new double*[dj+1];
  mo62cr=new double*[dj+1];mo62ci=new double*[dj+1];
  mo63cr=new double*[dj+1];mo63ci=new double*[dj+1];
  mo64cr=new double*[dj+1];mo64ci=new double*[dj+1];
  mo65cr=new double*[dj+1];mo65ci=new double*[dj+1];
  mo66cr=new double*[dj+1];mo66ci=new double*[dj+1];

    for (i=1;i<=dj;++i)
     {Jxr[i]=new double [dj];Jxi[i]=new double [dj];
      Jyr[i]=new double [dj];Jyi[i]=new double [dj];
      Jzr[i]=new double [dj];Jzi[i]=new double [dj];
      hcfr[i]=new double [dj];hcfi[i]=new double [dj];

    mo22sr[i]=new double [dj];mo22si[i]=new double [dj];
    mo21sr[i]=new double [dj];mo21si[i]=new double [dj];
    mo20cr[i]=new double [dj];mo20ci[i]=new double [dj];
    mo21cr[i]=new double [dj];mo21ci[i]=new double [dj];
    mo22cr[i]=new double [dj];mo22ci[i]=new double [dj];

    mo33sr[i]=new double [dj];mo33si[i]=new double [dj];
    mo32sr[i]=new double [dj];mo32si[i]=new double [dj];
    mo31sr[i]=new double [dj];mo31si[i]=new double [dj];
    mo30cr[i]=new double [dj];mo30ci[i]=new double [dj];
    mo31cr[i]=new double [dj];mo31ci[i]=new double [dj];
    mo32cr[i]=new double [dj];mo32ci[i]=new double [dj];
    mo33cr[i]=new double [dj];mo33ci[i]=new double [dj];

    mo44sr[i]=new double [dj];mo44si[i]=new double [dj];
    mo43sr[i]=new double [dj];mo43si[i]=new double [dj];
    mo42sr[i]=new double [dj];mo42si[i]=new double [dj];
    mo41sr[i]=new double [dj];mo41si[i]=new double [dj];
    mo40cr[i]=new double [dj];mo40ci[i]=new double [dj];
    mo41cr[i]=new double [dj];mo41ci[i]=new double [dj];
    mo42cr[i]=new double [dj];mo42ci[i]=new double [dj];
    mo43cr[i]=new double [dj];mo43ci[i]=new double [dj];
    mo44cr[i]=new double [dj];mo44ci[i]=new double [dj];

    mo55sr[i]=new double [dj];mo55si[i]=new double [dj];
    mo54sr[i]=new double [dj];mo54si[i]=new double [dj];
    mo53sr[i]=new double [dj];mo53si[i]=new double [dj];
    mo52sr[i]=new double [dj];mo52si[i]=new double [dj];
    mo51sr[i]=new double [dj];mo51si[i]=new double [dj];
    mo50cr[i]=new double [dj];mo50ci[i]=new double [dj];
    mo51cr[i]=new double [dj];mo51ci[i]=new double [dj];
    mo52cr[i]=new double [dj];mo52ci[i]=new double [dj];
    mo53cr[i]=new double [dj];mo53ci[i]=new double [dj];
    mo54cr[i]=new double [dj];mo54ci[i]=new double [dj];
    mo55cr[i]=new double [dj];mo55ci[i]=new double [dj];

    mo66sr[i]=new double [dj];mo66si[i]=new double [dj];
    mo65sr[i]=new double [dj];mo65si[i]=new double [dj];
    mo64sr[i]=new double [dj];mo64si[i]=new double [dj];
    mo63sr[i]=new double [dj];mo63si[i]=new double [dj];
    mo62sr[i]=new double [dj];mo62si[i]=new double [dj];
    mo61sr[i]=new double [dj];mo61si[i]=new double [dj];
    mo60cr[i]=new double [dj];mo60ci[i]=new double [dj];
    mo61cr[i]=new double [dj];mo61ci[i]=new double [dj];
    mo62cr[i]=new double [dj];mo62ci[i]=new double [dj];
    mo63cr[i]=new double [dj];mo63ci[i]=new double [dj];
    mo64cr[i]=new double [dj];mo64ci[i]=new double [dj];
    mo65cr[i]=new double [dj];mo65ci[i]=new double [dj];
    mo66cr[i]=new double [dj];mo66ci[i]=new double [dj];
    }
     

if (pr==1) printf("#using cfield ...\n");

  
  fprintf(stderr,"# module cfield ... for ion %s\n",iontype);
  cfield_mcphasnew(iontype,Jxr,Jxi,  Jyr, Jyi, Jzr, Jzi,
  mo22sr,mo22si,
  mo21sr,mo21si,
  mo20cr,mo20ci,
  mo21cr,mo21ci,
  mo22cr,mo22ci,

  mo33sr,mo33si,
  mo32sr,mo32si,
  mo31sr,mo31si,
  mo30cr,mo30ci,
  mo31cr,mo31ci,
  mo32cr,mo32ci,
  mo33cr,mo33ci,

  mo44sr,mo44si,
  mo43sr,mo43si,
  mo42sr,mo42si,
  mo41sr,mo41si,
  mo40cr,mo40ci,
  mo41cr,mo41ci,
  mo42cr,mo42ci,
  mo43cr,mo43ci,
  mo44cr,mo44ci,

  mo55sr,mo55si,
  mo54sr,mo54si,
  mo53sr,mo53si,
  mo52sr,mo52si,
  mo51sr,mo51si,
  mo50cr,mo50ci,
  mo51cr,mo51ci,
  mo52cr,mo52ci,
  mo53cr,mo53ci,
  mo54cr,mo54ci,
  mo55cr,mo55ci,

  mo66sr,mo66si,
  mo65sr,mo65si,
  mo64sr,mo64si,
  mo63sr,mo63si,
  mo62sr,mo62si,
  mo61sr,mo61si,
  mo60cr,mo60ci,
  mo61cr,mo61ci,
  mo62cr,mo62ci,
  mo63cr,mo63ci,
  mo64cr,mo64ci,
  mo65cr,mo65ci,
  mo66cr,mo66ci,

  &dimj,&alpha,&beta,&gamma,&gJ,&r2,&r4,&r6);



if (pr==1) printf("#end using cfield\n");

   J=((double)dimj-1)/2; //momentum quantum number

if (pr==1) printf("#J=%g\n",J);

   Ja = Matrix(1,dimj,1,dimj); 
   Jaa = ComplexMatrix(1,dimj,1,dimj); 
   for(i=1;i<=dimj;++i)for(j=1;j<=dimj;++j)
   {Jaa(i,j)=im*(Jxi[i])[j]+(Jxr[i])[j];
    if(i<j){Ja(i,j)=(Jxi[j])[i];}else{Ja(i,j)=(Jxr[i])[j];}
   }

   Jb = Matrix(1,dimj,1,dimj); 
   Jbb = ComplexMatrix(1,dimj,1,dimj); 
   for(i=1;i<=dimj;++i)for(j=1;j<=dimj;++j)
   {Jbb(i,j)=im*(Jyi[i])[j]+(Jyr[i])[j];
    if(i<j){Jb(i,j)=(Jyi[j])[i];}else{Jb(i,j)=(Jyr[i])[j];}
   }

   Jc = Matrix(1,dimj,1,dimj); 
   Jcc = ComplexMatrix(1,dimj,1,dimj); 
   for(i=1;i<=dimj;++i)for(j=1;j<=dimj;++j)
   {Jcc(i,j)=im*(Jzi[i])[j]+(Jzr[i])[j];
    if(i<j){Jc(i,j)=(Jzi[j])[i];}else{Jc(i,j)=(Jzr[i])[j];}
   }

//---------------------------------------------------------------------------

   Olm = new Matrix * [1+NOF_OLM_MATRICES];  // define array of pointers to our Olm matrices
   OOlm= new ComplexMatrix * [1+NOF_OLM_MATRICES]; 
   
   for(i=1;i<=NOF_OLM_MATRICES;++i)   
    {   Olm[i]= new Matrix(1,dimj,1,dimj); 
 // define memory for all matrices 
        OOlm [i] = new ComplexMatrix(1,dimj,1,dimj); 
    }   
    
    
   for(i=1;i<=dimj;++i){for(j=1;j<=dimj;++j)
   {(*OOlm[1])(i,j)=im*(mo22si[i])[j]+(mo22sr[i])[j];
if(i<j){(*Olm[1])(i,j)=(mo22si[j])[i];}else{(*Olm[1])(i,j)=(mo22sr[i])[j];}
    (*OOlm[2])(i,j)=im*(mo21si[i])[j]+(mo21sr[i])[j];
if(i<j){(*Olm[2])(i,j)=(mo21si[j])[i];}else{(*Olm[2])(i,j)=(mo21sr[i])[j];}
    (*OOlm[3])(i,j)=im*(mo20ci[i])[j]+(mo20cr[i])[j];
if(i<j){(*Olm[3])(i,j)=(mo20ci[j])[i];}else{(*Olm[3])(i,j)=(mo20cr[i])[j];}
    (*OOlm[4])(i,j)=im*(mo21ci[i])[j]+(mo21cr[i])[j];
if(i<j){(*Olm[4])(i,j)=(mo21ci[j])[i];}else{(*Olm[4])(i,j)=(mo21cr[i])[j];}
    (*OOlm[5])(i,j)=im*(mo22ci[i])[j]+(mo22cr[i])[j];
if(i<j){(*Olm[5])(i,j)=(mo22ci[j])[i];}else{(*Olm[5])(i,j)=(mo22cr[i])[j];}
    
    (*OOlm[6])(i,j)=im*(mo33si[i])[j]+(mo33sr[i])[j];
if(i<j){(*Olm[6])(i,j)=(mo33si[j])[i];}else{(*Olm[6])(i,j)=(mo33sr[i])[j];}
    (*OOlm[7])(i,j)=im*(mo32si[i])[j]+(mo32sr[i])[j];
if(i<j){(*Olm[7])(i,j)=(mo32si[j])[i];}else{(*Olm[7])(i,j)=(mo32sr[i])[j];}
    (*OOlm[8])(i,j)=im*(mo31si[i])[j]+(mo31sr[i])[j];
if(i<j){(*Olm[8])(i,j)=(mo31si[j])[i];}else{(*Olm[8])(i,j)=(mo31sr[i])[j];}
    (*OOlm[9])(i,j)=im*(mo30ci[i])[j]+(mo30cr[i])[j];
if(i<j){(*Olm[9])(i,j)=(mo30ci[j])[i];}else{(*Olm[9])(i,j)=(mo30cr[i])[j];}
    (*OOlm[10])(i,j)=im*(mo31ci[i])[j]+(mo31cr[i])[j];
if(i<j){(*Olm[10])(i,j)=(mo31ci[j])[i];}else{(*Olm[10])(i,j)=(mo31cr[i])[j];}
    (*OOlm[11])(i,j)=im*(mo32ci[i])[j]+(mo32cr[i])[j];
if(i<j){(*Olm[11])(i,j)=(mo32ci[j])[i];}else{(*Olm[11])(i,j)=(mo32cr[i])[j];}
    (*OOlm[12])(i,j)=im*(mo33ci[i])[j]+(mo33cr[i])[j];
if(i<j){(*Olm[12])(i,j)=(mo33ci[j])[i];}else{(*Olm[12])(i,j)=(mo33cr[i])[j];}
    
    (*OOlm[13])(i,j)=im*(mo44si[i])[j]+(mo44sr[i])[j];
if(i<j){(*Olm[13])(i,j)=(mo44si[j])[i];}else{(*Olm[13])(i,j)=(mo44sr[i])[j];}
    (*OOlm[14])(i,j)=im*(mo43si[i])[j]+(mo43sr[i])[j];
if(i<j){(*Olm[14])(i,j)=(mo43si[j])[i];}else{(*Olm[14])(i,j)=(mo43sr[i])[j];}
    (*OOlm[15])(i,j)=im*(mo42si[i])[j]+(mo42sr[i])[j];
if(i<j){(*Olm[15])(i,j)=(mo42si[j])[i];}else{(*Olm[15])(i,j)=(mo42sr[i])[j];}
    (*OOlm[16])(i,j)=im*(mo41si[i])[j]+(mo41sr[i])[j];
if(i<j){(*Olm[16])(i,j)=(mo41si[j])[i];}else{(*Olm[16])(i,j)=(mo41sr[i])[j];}
    (*OOlm[17])(i,j)=im*(mo40ci[i])[j]+(mo40cr[i])[j];
if(i<j){(*Olm[17])(i,j)=(mo40ci[j])[i];}else{(*Olm[17])(i,j)=(mo40cr[i])[j];}
    (*OOlm[18])(i,j)=im*(mo41ci[i])[j]+(mo41cr[i])[j];
if(i<j){(*Olm[18])(i,j)=(mo41ci[j])[i];}else{(*Olm[18])(i,j)=(mo41cr[i])[j];}
    (*OOlm[19])(i,j)=im*(mo42ci[i])[j]+(mo42cr[i])[j];
if(i<j){(*Olm[19])(i,j)=(mo42ci[j])[i];}else{(*Olm[19])(i,j)=(mo42cr[i])[j];}
    (*OOlm[20])(i,j)=im*(mo43ci[i])[j]+(mo43cr[i])[j];
if(i<j){(*Olm[20])(i,j)=(mo43ci[j])[i];}else{(*Olm[20])(i,j)=(mo43cr[i])[j];}
    (*OOlm[21])(i,j)=im*(mo44ci[i])[j]+(mo44cr[i])[j];
if(i<j){(*Olm[21])(i,j)=(mo44ci[j])[i];}else{(*Olm[21])(i,j)=(mo44cr[i])[j];}
    
    (*OOlm[22])(i,j)=im*(mo55si[i])[j]+(mo55sr[i])[j];
if(i<j){(*Olm[22])(i,j)=(mo55si[j])[i];}else{(*Olm[22])(i,j)=(mo55sr[i])[j];}
    (*OOlm[23])(i,j)=im*(mo54si[i])[j]+(mo54sr[i])[j];
if(i<j){(*Olm[23])(i,j)=(mo54si[j])[i];}else{(*Olm[23])(i,j)=(mo54sr[i])[j];}
    (*OOlm[24])(i,j)=im*(mo53si[i])[j]+(mo53sr[i])[j];
if(i<j){(*Olm[24])(i,j)=(mo53si[j])[i];}else{(*Olm[24])(i,j)=(mo53sr[i])[j];}
    (*OOlm[25])(i,j)=im*(mo52si[i])[j]+(mo52sr[i])[j];
if(i<j){(*Olm[25])(i,j)=(mo52si[j])[i];}else{(*Olm[25])(i,j)=(mo52sr[i])[j];}
    (*OOlm[26])(i,j)=im*(mo51si[i])[j]+(mo51sr[i])[j];
if(i<j){(*Olm[26])(i,j)=(mo51si[j])[i];}else{(*Olm[26])(i,j)=(mo51sr[i])[j];}
    (*OOlm[27])(i,j)=im*(mo50ci[i])[j]+(mo50cr[i])[j];
if(i<j){(*Olm[27])(i,j)=(mo50ci[j])[i];}else{(*Olm[27])(i,j)=(mo50cr[i])[j];}
    (*OOlm[28])(i,j)=im*(mo51ci[i])[j]+(mo51cr[i])[j];
if(i<j){(*Olm[28])(i,j)=(mo51ci[j])[i];}else{(*Olm[28])(i,j)=(mo51cr[i])[j];}
    (*OOlm[29])(i,j)=im*(mo52ci[i])[j]+(mo52cr[i])[j];
if(i<j){(*Olm[29])(i,j)=(mo52ci[j])[i];}else{(*Olm[29])(i,j)=(mo52cr[i])[j];}
    (*OOlm[30])(i,j)=im*(mo53ci[i])[j]+(mo53cr[i])[j];
if(i<j){(*Olm[30])(i,j)=(mo53ci[j])[i];}else{(*Olm[30])(i,j)=(mo53cr[i])[j];}
    (*OOlm[31])(i,j)=im*(mo54ci[i])[j]+(mo54cr[i])[j];
if(i<j){(*Olm[31])(i,j)=(mo54ci[j])[i];}else{(*Olm[31])(i,j)=(mo54cr[i])[j];}
    (*OOlm[32])(i,j)=im*(mo55ci[i])[j]+(mo55cr[i])[j];
if(i<j){(*Olm[32])(i,j)=(mo55ci[j])[i];}else{(*Olm[32])(i,j)=(mo55cr[i])[j];}
    
    (*OOlm[33])(i,j)=im*(mo66si[i])[j]+(mo66sr[i])[j];
if(i<j){(*Olm[33])(i,j)=(mo66si[j])[i];}else{(*Olm[33])(i,j)=(mo66sr[i])[j];}
    (*OOlm[34])(i,j)=im*(mo65si[i])[j]+(mo65sr[i])[j];
if(i<j){(*Olm[34])(i,j)=(mo65si[j])[i];}else{(*Olm[34])(i,j)=(mo65sr[i])[j];}
    (*OOlm[35])(i,j)=im*(mo64si[i])[j]+(mo64sr[i])[j];
if(i<j){(*Olm[35])(i,j)=(mo64si[j])[i];}else{(*Olm[35])(i,j)=(mo64sr[i])[j];}
    (*OOlm[36])(i,j)=im*(mo63si[i])[j]+(mo63sr[i])[j];
if(i<j){(*Olm[36])(i,j)=(mo63si[j])[i];}else{(*Olm[36])(i,j)=(mo63sr[i])[j];}
    (*OOlm[37])(i,j)=im*(mo62si[i])[j]+(mo62sr[i])[j];
if(i<j){(*Olm[37])(i,j)=(mo62si[j])[i];}else{(*Olm[37])(i,j)=(mo62sr[i])[j];}
    (*OOlm[38])(i,j)=im*(mo61si[i])[j]+(mo61sr[i])[j];
if(i<j){(*Olm[38])(i,j)=(mo61si[j])[i];}else{(*Olm[38])(i,j)=(mo61sr[i])[j];}
    (*OOlm[39])(i,j)=im*(mo60ci[i])[j]+(mo60cr[i])[j];
if(i<j){(*Olm[39])(i,j)=(mo60ci[j])[i];}else{(*Olm[39])(i,j)=(mo60cr[i])[j];}
    (*OOlm[40])(i,j)=im*(mo61ci[i])[j]+(mo61cr[i])[j];
if(i<j){(*Olm[40])(i,j)=(mo61ci[j])[i];}else{(*Olm[40])(i,j)=(mo61cr[i])[j];}
    (*OOlm[41])(i,j)=im*(mo62ci[i])[j]+(mo62cr[i])[j];
if(i<j){(*Olm[41])(i,j)=(mo62ci[j])[i];}else{(*Olm[41])(i,j)=(mo62cr[i])[j];}
    (*OOlm[42])(i,j)=im*(mo63ci[i])[j]+(mo63cr[i])[j];
if(i<j){(*Olm[42])(i,j)=(mo63ci[j])[i];}else{(*Olm[42])(i,j)=(mo63cr[i])[j];}
    (*OOlm[43])(i,j)=im*(mo64ci[i])[j]+(mo64cr[i])[j];
if(i<j){(*Olm[43])(i,j)=(mo64ci[j])[i];}else{(*Olm[43])(i,j)=(mo64cr[i])[j];}
    (*OOlm[44])(i,j)=im*(mo65ci[i])[j]+(mo65cr[i])[j];
if(i<j){(*Olm[44])(i,j)=(mo65ci[j])[i];}else{(*Olm[44])(i,j)=(mo65cr[i])[j];}
    (*OOlm[45])(i,j)=im*(mo66ci[i])[j]+(mo66cr[i])[j];
if(i<j){(*Olm[45])(i,j)=(mo66ci[j])[i];}else{(*Olm[45])(i,j)=(mo66cr[i])[j];}
    
   }}

// ------------------------------------------------------------
   


   
    for (i=1;i<=dj;++i)
     {delete[]Jxr[i];delete[]Jxi[i];
      delete[]Jyr[i];delete[]Jyi[i];
      delete[]Jzr[i];delete[]Jzi[i];
      delete[]hcfr[i];delete[]hcfi[i];

   delete[]mo22sr[i];delete[]mo22si[i];
   delete[]mo21sr[i];delete[]mo21si[i];
   delete[]mo20cr[i];delete[]mo20ci[i];
   delete[]mo21cr[i];delete[]mo21ci[i];
   delete[]mo22cr[i];delete[]mo22ci[i];

   delete[]mo33sr[i];delete[]mo33si[i];
   delete[]mo32sr[i];delete[]mo32si[i];
   delete[]mo31sr[i];delete[]mo31si[i];
   delete[]mo30cr[i];delete[]mo30ci[i];
   delete[]mo31cr[i];delete[]mo31ci[i];
   delete[]mo32cr[i];delete[]mo32ci[i];
   delete[]mo33cr[i];delete[]mo33ci[i];

   delete[]mo44sr[i];delete[]mo44si[i];
   delete[]mo43sr[i];delete[]mo43si[i];
   delete[]mo42sr[i];delete[]mo42si[i];
   delete[]mo41sr[i];delete[]mo41si[i];
   delete[]mo40cr[i];delete[]mo40ci[i];
   delete[]mo41cr[i];delete[]mo41ci[i];
   delete[]mo42cr[i];delete[]mo42ci[i];
   delete[]mo43cr[i];delete[]mo43ci[i];
   delete[]mo44cr[i];delete[]mo44ci[i];

   delete[]mo55sr[i];delete[]mo55si[i];
   delete[]mo54sr[i];delete[]mo54si[i];
   delete[]mo53sr[i];delete[]mo53si[i];
   delete[]mo52sr[i];delete[]mo52si[i];
   delete[]mo51sr[i];delete[]mo51si[i];
   delete[]mo50cr[i];delete[]mo50ci[i];
   delete[]mo51cr[i];delete[]mo51ci[i];
   delete[]mo52cr[i];delete[]mo52ci[i];
   delete[]mo53cr[i];delete[]mo53ci[i];
   delete[]mo54cr[i];delete[]mo54ci[i];
   delete[]mo55cr[i];delete[]mo55ci[i];

   delete[]mo66sr[i];delete[]mo66si[i];
   delete[]mo65sr[i];delete[]mo65si[i];
   delete[]mo64sr[i];delete[]mo64si[i];
   delete[]mo63sr[i];delete[]mo63si[i];
   delete[]mo62sr[i];delete[]mo62si[i];
   delete[]mo61sr[i];delete[]mo61si[i];
   delete[]mo60cr[i];delete[]mo60ci[i];
   delete[]mo61cr[i];delete[]mo61ci[i];
   delete[]mo62cr[i];delete[]mo62ci[i];
   delete[]mo63cr[i];delete[]mo63ci[i];
   delete[]mo64cr[i];delete[]mo64ci[i];
   delete[]mo65cr[i];delete[]mo65ci[i];
   delete[]mo66cr[i];delete[]mo66ci[i];
   }

     delete[]Jxr;delete[]Jxi;
     delete[]Jyr;delete[]Jyi;
     delete[]Jzr;delete[]Jzi;
     delete[]hcfr;delete[]hcfi;

   delete []mo22sr;delete []mo22si;
   delete []mo21sr;delete []mo21si;
   delete []mo20cr;delete []mo20ci;
   delete []mo21cr;delete []mo21ci;
   delete []mo22cr;delete []mo22ci;

   delete []mo33sr;delete []mo33si;
   delete []mo32sr;delete []mo32si;
   delete []mo31sr;delete []mo31si;
   delete []mo30cr;delete []mo30ci;
   delete []mo31cr;delete []mo31ci;
   delete []mo32cr;delete []mo32ci;
   delete []mo33cr;delete []mo33ci;

   delete []mo44sr;delete []mo44si;
   delete []mo43sr;delete []mo43si;
   delete []mo42sr;delete []mo42si;
   delete []mo41sr;delete []mo41si;
   delete []mo40cr;delete []mo40ci;
   delete []mo41cr;delete []mo41ci;
   delete []mo42cr;delete []mo42ci;
   delete []mo43cr;delete []mo43ci;
   delete []mo44cr;delete []mo44ci;

   delete []mo55sr;delete []mo55si;
   delete []mo54sr;delete []mo54si;
   delete []mo53sr;delete []mo53si;
   delete []mo52sr;delete []mo52si;
   delete []mo51sr;delete []mo51si;
   delete []mo50cr;delete []mo50ci;
   delete []mo51cr;delete []mo51ci;
   delete []mo52cr;delete []mo52ci;
   delete []mo53cr;delete []mo53ci;
   delete []mo54cr;delete []mo54ci;
   delete []mo55cr;delete []mo55ci;

   delete []mo66sr;delete []mo66si;
   delete []mo65sr;delete []mo65si;
   delete []mo64sr;delete []mo64si;
   delete []mo63sr;delete []mo63si;
   delete []mo62sr;delete []mo62si;
   delete []mo61sr;delete []mo61si;
   delete []mo60cr;delete []mo60ci;
   delete []mo61cr;delete []mo61ci;
   delete []mo62cr;delete []mo62ci;
   delete []mo63cr;delete []mo63ci;
   delete []mo64cr;delete []mo64ci;
   delete []mo65cr;delete []mo65ci;
   delete []mo66cr;delete []mo66ci;
   
  Hcf= Matrix(1,dimj,1,dimj); 
  Hcf=0;

   if(Hcf==(double)0.0){
   // calculation of the cf matrix according 
   fprintf(stderr,"crystal field parameters\n");  
   for(l=1;l<=45;++l){Hcf+=Blm(l)*(*Olm[l]);
                   if(Blm(l)!=0){if(l<24){fprintf(stderr,"B%c=%g   ",l+99,Blm(l));}
		                     else{fprintf(stderr,"B(z+%i)=%g   ",l-23,Blm(l));}
		                }
                  }
   }
   
//ATTENTION FOR NDCU2 the AXES xyz are parallel to cab
Matrix dummy(1,dimj,1,dimj);
dummy=Jb;Jb=Jc;Jc=Ja;Ja=dummy;
ComplexMatrix dummyc(1,dimj,1,dimj);
dummyc=Jbb;Jbb=Jcc;Jcc=Jaa;Jaa=dummyc;

if (pr==1) {printf("#Axis Convention using cfield as a module:  a||y b||z  c||x\n");
printf("#xyz .... Coordinate system of the crystal field parameters used in cfield\n");
printf("#abc .... Crystal axes\n");
printf("#The interactions are described by the  PKQ Operators defined in cfield\n");
printf("#O11(s) .... Ja=Jy\n");
printf("#O10(c) .... Jb=Jz\n");
printf("#O11(c) .... Jc=Jx\n");
printf("#O22(s) .... Jd\n");
printf("#O21(s) .... Je\n");
printf("#O20(c) .... Jf\n");
printf("#O21(c) .... Jg\n");
printf("#O22(c) .... Jh\n");
printf("#O33(s) .... Ji\n");
printf("#O32(s) .... Jj\n");
printf("#O31(s) .... Jk\n");
printf("#O30(c) .... Jl\n");
printf("#O31(c) .... Jm\n");
printf("# etc ... 45 moments up to l<=6\n");
printf("#\n");
}

pr=0;
}


//------------------------------------------------------------------------------------------------
// ROUTINE CFIELD for full crystal field + higher order interactions
//------------------------------------------------------------------------------------------------
Vector & ionpars::cfield(double & T, Vector & gjmbH, double & lnZs, double & U)
{//ABC not used !!!
    /*on input
    T		temperature[K]
    gJmbH	vector of effective field [meV]
    gJ          Lande factor
    ABC         single ion parameter values (A, B, C corresponding to <+|Ja|->,<-|Jb|->,<+|Jc|->/i
  on output    
    J		single ion momentum vector <J> (if T>0 thermal exp value <J>T 
                                                if T<0 the program asks for w_n and calculates
						       exp value <J>=sum_n w_n <n|J|n>
						       
    Z		single ion partition function
    U		single ion magnetic energy
*/

// check dimensions of vector
if(gjmbH.Hi()>48)
   {fprintf(stderr,"Error internal module cfield: wrong number of dimensions - check number of columns in file mcphas.j\n");
    exit(EXIT_FAILURE);}

//  Driver routine to compute the  eigenvalues and normalized eigenvectors 
//  of a complex Hermitian matrix z.The real parts of the elements must be
//  stored in the lower triangle of z,the imaginary parts (of the elements
//  corresponding to the lower triangle) in the positions
//  of the upper triangle of z[lo..hi,lo..hi].The eigenvalues are returned
//  in d[lo..hi] in ascending numerical  order if the sort flag is set  to
//  True, otherwise  not ordered for sort = False. The real  and imaginary
//  parts of the eigenvectors are  returned in  the columns of  zr and zi. 
//  The storage requirement is 3*n*n + 4*n complex numbers. 
//  All matrices and vectors have to be allocated and removed by the user.
//  They are checked for conformance !
// void  EigenSystemHermitean (Matrix& z, Vector& d, Matrix& zr, Matrix& zi, 
// 			   int sort, int maxiter)
static Vector JJ(1,gjmbH.Hi());
   // setup hamiltonian
   int dj,j;
   dj=Hcf.Rhi();
   Matrix Ham(1,dj,1,dj);
   ComplexMatrix z(1,dj,1,dj);
   ComplexMatrix za(1,dj,1,dj);
   ComplexMatrix zb(1,dj,1,dj);
   ComplexMatrix zc(1,dj,1,dj);
   ComplexMatrix zolm(1,dj,1,dj);    

   Ham=Hcf-gjmbH(1)*Ja-gjmbH(2)*Jb-gjmbH(3)*Jc;

   for(j=4;j<=JJ.Hi();++j){Ham-=gjmbH(j)*(*Olm[j-3]);}

/*   int i1,j1; //printout matrix
   for (i1=1;i1<=dj;++i1){
    for (j1=1;j1<=dj;++j1) printf ("%4.6g ",(*Olm[j])(i1,j1));
    printf ("\n");
    }*/
      
    
   // diagonalize
   Vector En(1,dj);Matrix zr(1,dj,1,dj);Matrix zi(1,dj,1,dj);
   int sort=0;int maxiter=1000000;
   if (T<0) sort=1;
   EigenSystemHermitean (Ham,En,zr,zi,sort,maxiter);

   // calculate Z and wn (occupation probability)
     Vector wn(1,dj);
     double x,y;int i;
     x=Min(En);
     double Zs;

     if (T>0)
     { for (i=1;i<=dj;++i)
       {if ((y=(En(i)-x)/K_B/T)<600) wn[i]=exp(-y); 
        else wn[i]=0.0;
       }
       Zs=Sum(wn);wn/=Zs;
 
       lnZs=log(Zs)-x/K_B/T;
     } 
     else
     { printf ("Temperature T<0: please choose probability distribution of states by hand\n");
                         printf ("Number   Energy     Excitation Energy\n");
     for (i=1;i<=dj;++i) printf ("%i    %4.4g meV   %4.4g meV\n",i,En(i),En(i)-x);
     char instr[MAXNOFCHARINLINE];
     for (i=1;i<=dj;++i)
      {printf("eigenstate %i: %4.4g meV %4.4g meV  - please enter probability w(%i):",i,En(i),En(i)-x,i);
       fgets(instr, MAXNOFCHARINLINE, stdin);
 
       wn(i)=strtod(instr,NULL);
      }
       Zs=Sum(wn);wn/=Zs;
 
       lnZs=log(Zs);
                         printf ("\n\nNumber   Energy     Excitation Energy   Probability\n");
     for (i=1;i<=dj;++i) printf ("%i    %4.4g meV   %4.4g meV %4.4g  \n",i,En(i),En(i)-x,wn(i));
     }

   // calculate U
     U=En*wn;
   // calculate Ja,Jb,Jc
     z=ComplexMatrix(zr,zi);
     
     za=Jaa*z;
     zb=Jbb*z;
     zc=Jcc*z;

    
     JJ=0;
//    ComplexVector ddd;
    for (i=1;i<=dj;++i)
    {
     JJ[1]+=wn(i)*real(z.Column(i)*za.Column(i));
     JJ[2]+=wn(i)*real(z.Column(i)*zb.Column(i));
     JJ[3]+=wn(i)*real(z.Column(i)*zc.Column(i));
    }
     
   for(j=4;j<=JJ.Hi();++j)
   {
    zolm=(*OOlm[j-3])*z;
    for (i=1;i<=dj;++i) JJ[j]+=wn(i)*real(z.Column(i)*zolm.Column(i));
   };
  

return JJ;
}
/**************************************************************************/

/**************************************************************************/
// for mcdisp this routine is needed
int ionpars::cfielddm(int & tn,double & T,Vector & gjmbH,ComplexMatrix & mat,float & delta)
{  /*on input
    tn      ... number of transition to be computed 
    ABC[i]	(not used)saturation moment/gJ[MU_B] of groundstate doublet in a.b.c direction
    gJ		lande factor
    T		temperature[K]
    gjmbH	vector of effective field [meV]
  on output    
    delta-+	energy of transition [meV]
    mat(i,j)	<-|Ji|+><+|Jj|-> (n+-n-),  n+,n-
    .... occupation number of states (- to + transition chosen according to transitionnumber)
*/


// check dimensions of vector
if(gjmbH.Hi()>48)
   {fprintf(stderr,"Error loadable module cfield.so: wrong number of dimensions - check number of columns in file mcphas.j\n");
    exit(EXIT_FAILURE);}

//  Driver routine to compute the  eigenvalues and normalized eigenvectors 
//  of a complex Hermitian matrix z.The real parts of the elements must be
//  stored in the lower triangle of z,the imaginary parts (of the elements
//  corresponding to the lower triangle) in the positions
//  of the upper triangle of z[lo..hi,lo..hi].The eigenvalues are returned
//  in d[lo..hi] in ascending numerical  order if the sort flag is set  to
//  True, otherwise  not ordered for sort = False. The real  and imaginary
//  parts of the eigenvectors are  returned in  the columns of  zr and zi. 
//  The storage requirement is 3*n*n + 4*n complex numbers. 
//  All matrices and vectors have to be allocated and removed by the user.
//  They are checked for conformance !
// void  EigenSystemHermitean (Matrix& z, Vector& d, Matrix& zr, Matrix& zi, 
// 			   int sort, int maxiter)

static Vector JJ(1,gjmbH.Hi());
double lnz,u;
JJ=cfield(T,gjmbH,lnz,u);  //expectation values <J>
  int pr;
  pr=1;
  if (tn<0) {pr=0;tn*=-1;}

   // setup hamiltonian
   int dj,j;
   dj=Hcf.Rhi();
   Matrix Ham(1,dj,1,dj);
    
   Ham=Hcf-gjmbH(1)*Ja-gjmbH(2)*Jb-gjmbH(3)*Jc;
 for(j=4;j<=gjmbH.Hi();++j){Ham-=gjmbH(j)*(*Olm[j-3]);}

/*   int i1,j1; //printout matrix
    printf ("\n");
   for (i1=1;i1<=dj;++i1){
    for (j1=1;j1<=dj;++j1) {printf ("%4.6g ",
    real(((*OOlm[5])-Jcc*Jcc+Jaa*Jaa)(i1,j1)));}
//    real((Jcc*Jaa+Jaa*Jcc)(i1,j1)));}
//    real((*OOlm[1])(i1,j1)));}
    printf ("\n");
    }
    printf ("\n");
   for (i1=1;i1<=dj;++i1){
    for (j1=1;j1<=dj;++j1) {printf ("%4.6g ",
    imag(((*OOlm[5])-Jcc*Jcc+Jaa*Jaa)(i1,j1)));}
//   imag((Jcc*Jaa+Jaa*Jcc)(i1,j1)));}
//   imag((*OOlm[1])(i1,j1)));}
    printf ("\n");
    }
exit(0);      
*/    
   // diagonalize
   Vector En(1,dj);Matrix zr(1,dj,1,dj);Matrix zi(1,dj,1,dj);
   int sort=1;int maxiter=1000000;
   EigenSystemHermitean (Ham,En,zr,zi,sort,maxiter);
   
   
   
   
   // calculate Z and wn (occupation probability)
     Vector wn(1,dj);double Zs;
     double x,y;int i,k,l,m;
     x=Min(En);
     for (i=1;i<=dj;++i)
     {if ((y=(En(i)-x)/K_B/T)<700) wn[i]=exp(-y); 
      else wn[i]=0.0;
//      printf("%4.4g\n",En(i));
      }
     Zs=Sum(wn);wn/=Zs;  
     Zs*=exp(-x/K_B/T);
   // calculate Ja,Jb,Jc
     ComplexMatrix z(1,dj,1,dj);
     ComplexMatrix * zp[gjmbH.Hi()+1];
     for(l=1;l<=gjmbH.Hi();++l)
      {zp[l]= new ComplexMatrix(1,dj,1,dj);}
     z=ComplexMatrix(zr,zi);
     
     (*zp[1])=Jaa*z;
     (*zp[2])=Jbb*z;
     (*zp[3])=Jcc*z;

     
 for(j=4;j<=gjmbH.Hi();++j)
    {(*zp[j])=(*OOlm[j-3])*z;}
     
// calculate mat and delta for transition number tn
// 1. get i and j from tn
k=0;
for(i=1;i<=dj;++i){for(j=i;j<=dj;++j)
{++k;if(k==tn)break;
}if(k==tn)break;}

// 2. set delta
delta=En(j)-En(i);

if (delta<-0.000001){fprintf(stderr,"ERROR module cfield.so - dmcalc: energy gain delta gets negative\n");exit(EXIT_FAILURE);}
if(j==i)delta=-SMALL; //if transition within the same level: take negative delta !!- this is needed in routine intcalc

// 3. set mat
for(l=1;l<=gjmbH.Hi();++l)for(m=1;m<=gjmbH.Hi();++m)
{if(i==j){//take into account thermal expectation values <Jl>
          mat(l,m)=((z.Column(i)*(*zp[l]).Column(j))-JJ(l))*((z.Column(j)*(*zp[m]).Column(i))-JJ(m));}
 else    {mat(l,m)=(z.Column(i)*(*zp[l]).Column(j))*(z.Column(j)*(*zp[m]).Column(i));}}



if (delta>SMALL)
   { if(pr==1){
      printf("delta(%i->%i)=%4.4gmeV",i,j,delta);
      printf(" |<%i|Ja|%i>|^2=%4.4g |<%i|Jb|%i>|^2=%4.4g |<%i|Jc|%i>|^2=%4.4g",i,j,real(mat(1,1)),i,j,real(mat(2,2)),i,j,real(mat(3,3)));
      printf(" n%i-n%i=%4.4g\n",i,j,wn(i)-wn(j));}
    mat*=(wn(i)-wn(j)); // occupation factor    
     }else
   {// quasielastic scattering has not wi-wj but wj*epsilon/kT
     if(pr==1){
      printf("delta(%i->%i)=%4.4gmeV",i,j,delta);
      printf(" |<%i|Ja-<Ja>|%i>|^2=%4.4g |<%i|Jb-<Jb>|%i>|^2=%4.4g |<%i|Jc-<Jc>|%i>|^2=%4.4g",i,j,real(mat(1,1)),i,j,real(mat(2,2)),i,j,real(mat(3,3)));
      printf(" n%i=%4.4g\n",i,wn(i));}
    mat*=(wn(i)/K_B/T);
   }

//clean up memory
     for(l=1;l<=gjmbH.Hi();++l)
      {delete zp[l];}
     
// return number of all transitions     
 return (int)((J+1)*(2*J+1)); 
}