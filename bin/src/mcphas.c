/**************************************************************************
 *
 * mcphas - program to calculate static magnetic properties (phase diagram)
 *
 * reference: M. Rotter JMMM 272-276 (2004) 481
 **************************************************************************/

#include<mcphas.h>

// maximum number of spinconfigurations allowed in phasediagramm
#define MAXNOFSPINCF 500



inipar ini("mcphas.ini");
int verbose=0;
const char * filemode="w";

#include "myev.h"
#include "mcphas_htcalc.c"
#include "mcphas_fecalc.c"
#include "mcphas_physpropcalc.c"

// main program
int main (int argc, char **argv)
{ FILE * fin=NULL; 
  //char instr[MAXNOFCHARINLINE];
  int im,j,l;
  int nofstapoints=0;
  int options=1; // this integer indicates how many command strings belong to options (=1+number of option-strings)
  float x,y,dumm;
  double z,u;
  double T;
  float nn[20];nn[0]=19;
  double sta=0;
  double stamax=1e33;
  Vector xv(1,3);
  Vector yv(1,3);
  Vector h(1,3);Vector mmax1(1,3);
  
fprintf(stderr,"**************************************************************************\n");
fprintf(stderr,"*\n");
fprintf(stderr,"* mcphas - program to calculate static magnetic properties (phase diagram)\n");
fprintf(stderr,"*\n");
fprintf(stderr,"* reference: M. Rotter JMMM 272-276 (2004) 481\n");
fprintf(stderr,"**************************************************************************\n\n");
  
// check command line
  for (im=1;im<=argc-1;++im)
  {if (strcmp(argv[im],"-v")==0) {verbose=1;if (options<im)options=im;}// set verbose mode on
   if (strcmp(argv[im],"-h")==0) ini.errexit(); // display help message
   if (strcmp(argv[im],"-a")==0) filemode="a"; // append output files
   if (strcmp(argv[im],"-stamax")==0&&im+1<=argc-1)
                                 {stamax=strtod (argv[im+1], NULL); // read stamax
                                  if (options<im)options=im+1;}
  }

  if (ini.exit_mcphas!=0)
  {ini.exit_mcphas=0;ini.print();} // if exit was 1 - save parameters and set exit=0
   ini.print("./results/_mcphas.ini");  // copy mcphas.ini to results directory


// as class par load  parameters from file
 if(verbose==1){printf("reading parameters from file mcphas.j\n");}
 par inputpars("./mcphas.j"); inputpars.save("./results/_mcphas.j"); 

  Vector mmax(1,inputpars.nofatoms*inputpars.nofcomponents);
  Vector mmom(1,inputpars.nofcomponents);
  Vector h1(1,inputpars.nofcomponents);
 
// here save single ion property files to results
inputpars.save_sipfs("./results/_");

//determine saturation momentum (used for scaling the plots, generation of qvectors)
T=1.0;for(l=1;l<=inputpars.nofatoms;++l){h1=0;(*inputpars.jjj[l]).mcalc_parameter_storage_init(h1,T); // initialize eigenstate matrix
      for (im=1;im<=inputpars.nofcomponents;++im){h1=0;
                            if((*inputpars.jjj[l]).gJ!=0){h1(im)=10*MU_B*(*inputpars.jjj[l]).gJ;}
                            else                         {h1(im)=20*MU_B;} //just put some high field
                            (*inputpars.jjj[l]).mcalc(mmom,T,h1,z,u,(*inputpars.jjj[l]).mcalc_parstorage);
                            mmax(inputpars.nofcomponents*(l-1)+im)=mmom(im);
                           //printf("mmax(%i)=%g\n",inputpars.nofcomponents*(l-1)+im,mmax(inputpars.nofcomponents*(l-1)+im));
			   }
                                        }
mmax1=0;for (im=1;im<=inputpars.nofcomponents&&im<=3;++im){mmax1(im)=mmax(im);}


T=0.0;h=0;
// load testspinconfigurations (nooftstspinconfigurations,init-file,sav-file)
   testspincf testspins (MAXNOFSPINCF,"./mcphas.tst","./results/mcphas.phs",inputpars.nofatoms,inputpars.nofcomponents);
   testspins.save("./results/_mcphas.tst","w");
   qvectors testqs (ini,inputpars.rez,mmax,"./results/mcphas.qvc",inputpars.nofatoms,inputpars.nofcomponents,verbose);

// declare variable physprop (typa class physproperties)
   physproperties physprop(ini.nofspincorrs,ini.maxnofhkls,inputpars.nofatoms,inputpars.nofcomponents);
   	
// transform mmax to contain saturation moments [muB] 
for(l=1;l<=inputpars.nofatoms;++l){for (im=1;im<=inputpars.nofcomponents&&im<=3;++im){if((*inputpars.jjj[l]).gJ!=0)mmax(3*(l-1)+im)*=inputpars.gJ(l);}}

if (argc>options&&strncmp(argv[argc-1],"-",1)!=0){ini.xv=0;ini.yv=0;fin=fopen_errchk (argv[argc-1],"rb");}   //input from file
// loop different H /T points in phase diagram
for (x=ini.xmin;x<=ini.xmax;x+=ini.xstep)
 { //begin initialize display file
   FILE * fout;fout = fopen_errchk ("./results/.mcphas.fum","w");
   fprintf (fout, " %4.4g %6.6g  %4.4g %4.4g %4.4g %4.4g %4.4g %8.8g %8.8g  %4.4g %4.4g %4.4g %4.4g\n",
            0.0,ini.ymin,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,-Max(mmax1),0.0,0.0);
   fprintf (fout, " %4.4g %6.6g  %4.4g %4.4g %4.4g %4.4g %4.4g %8.8g %8.8g  %4.4g %4.4g %4.4g %4.4g\n",
            0.0,ini.ymax+1e-4,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,Max(mmax1),0.0,0.0);
   fclose(fout); //end initialize display file
  
  for (y=ini.ymin;y<=ini.ymax;y+=ini.ystep)
  {//correct some of input errors in parameters ini (if there are any)
   if (ini.xstep<0){ini.xstep=-ini.xstep;}
   if (ini.ystep<0){ini.ystep=-ini.ystep;}
   if (ini.xmin>ini.xmax){dumm=ini.xmin;ini.xmin=ini.xmax;ini.xmax=dumm;}
   if (ini.ymin>ini.ymax){dumm=ini.ymin;ini.ymin=ini.ymax;ini.ymax=dumm;}
   
   if(argc>1&&strncmp(argv[argc-1],"-",1)!=0)  //should T-H values be read from file ?
   {while (feof(fin)==0&&0==inputline(fin,nn));  // if yes -> input them
    if (feof(fin)!=0) goto endproper;
    x=nn[1];y=nn[2];T=nn[3];h(1)=nn[5];h(2)=nn[6];h(3)=nn[7];
    normalizedadbdc(h,nn[4],inputpars);
   }
   else
   {//if parameters outside specified region then put them into it ...
    xv=ini.xv(1,3);normalizedadbdc(xv,1.0,inputpars);
    yv=ini.yv(1,3);normalizedadbdc(yv,1.0,inputpars);
    if (x<ini.xmin) x=ini.xmin;
    if (y<ini.ymin) y=ini.ymin;    

     T=ini.zero(0)+x*ini.xv(0)+y*ini.yv(0);
     h(1)=ini.zero(1)+x*xv(1)+y*yv(1);
     h(2)=ini.zero(2)+x*xv(2)+y*yv(2);
     h(3)=ini.zero(3)+x*xv(3)+y*yv(3);
   } 
     
      physprop.x=x;physprop.y=y;
      physprop.T=T;
      physprop.H=h;

//calculate physical properties at HT- point
      j=htcalc(physprop.H,T,inputpars,testqs,testspins,physprop);
       switch (j)
       {case 0:
            //save physical properties of HT-point
	    //sta=(sta*nofstapoints+physprop.save (verbose,filemode,j,inputpars))/(nofstapoints+1);
          // 12.3.07 fancy calculation above substituted by normal summing of sta
          sta+=physprop.save (verbose,filemode,j,inputpars);
	    ++nofstapoints;
          if (sta>stamax){fprintf(stdout,"stamax=%g exceeded - exiting\n",stamax);goto endproper;}
	      break; 
	 case 1: goto endproper;
	      break;
         case 2: //ht calculation leads to no results- save dummy line
	         physprop.save (verbose,filemode,j,inputpars);
		 sta+=1.0; // increment sta because within manifold of spincf no good solution could be found
	      break;	 
	 default:  ;
	}
 if(fin!=NULL){y=ini.ymin-ini.ystep;} // this is to switch off xy loop if xy points are read from file

    }
 }  
endproper:
  testspins.save(filemode);testqs.save(filemode);
   if(argc>options&&strncmp(argv[argc-1],"-",1)!=0) fclose(fin);
   printf("RESULTS saved in directory ./results/  - files:\n");
   printf("  mcphas.fum  - total magnetic moment, energy at different T,H\n");
   printf("  mcphas.sps  - stable configurations at different T,H\n");
   printf("  mcphas.mf   - mean fields at different T,H\n");
   printf("  mcphas.hkl  - strong magnetic satellites, neutron diffraction intensity\n");
   printf("  mcphas*.hkl - strong magnetic satellites, Fourier Comp.of moment in * dir\n");
   printf("  mcphas*.j*  - JJ correlation functions (for exchange magnetostriction)\n");
   printf("  mcphas.xyt  - phasediagram (stable conf.nr, angular and multipolar moments)\n");
   printf("  mcphas.qvc  - ...corresponding table of all qvector generated test configs\n");
   printf("  mcphas.phs  - ...corresponding table of all test configurations (except qvecs)\n");
   printf("  _mcphas.*   - parameters read from input parameter files (.tst,.ini,.j)\n");
   printf("  ...         - and a copy of the single ion parameter files used.\n\n");
   fprintf(stdout,"sta=%g\n",sta);
   fprintf(stderr,"**********************************************\n");
   fprintf(stderr,"          End of Program mcphas\n");
   fprintf(stderr," reference: M. Rotter JMMM 272-276 (2004) 481\n");
   fprintf(stderr,"**********************************************\n");

return(0);
}

int normalizedadbdc(Vector & dadbdc,double n,par & inputpars)
   {if(Norm(dadbdc)>0.00001){ // normalize Vector dadbdc to length n
    Vector Hijk(1,3);
    Vector abc(1,6); abc(1)=1; abc(2)=1; abc(3)=1;
                     abc(4)=inputpars.alpha; abc(5)=inputpars.beta; abc(6)=inputpars.gamma;
    dadbdc2ijk(Hijk,dadbdc,abc);
    Hijk*=n/Norm(Hijk);
    ijk2dadbdc(dadbdc,Hijk,abc);
    return true;      }
    else
   {return false;}
   }