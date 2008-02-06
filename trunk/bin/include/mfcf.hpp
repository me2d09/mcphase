// klasse testmfcf to store mean field configuration

#include<cstdlib>
#include<cerrno>
#include<vector.h>
#include<complex>

#ifndef MFCF_H
#define MFCF_H

class mfcf 
{
  private:
 // number of spins  
   int nofa,nofb,nofc;
 // this subtracts n2 if n1>n2
   int mod(int n1,int n2);
   int mxa,mxb,mxc;
 // frame of display
   Vector * mfi; // mean fields = gjmbHeff [meV]
   int iv[4];
          
  public:
   int nofatoms;
   int nofcomponents;
 // array of spins 
   int in(int i,int j, int k); 
    int wasstable; // index to remember if it was stable
   
    Vector & mf(int i,int j,int k); // returns pointer to mean field (ijk) 
    Vector & mi(int in); // returns pointer to mean field i
    int * ijk(int in);  // returns mf indizes (ijk)(in): in=0,...,n(=na*nb*nc)
    
    int n(); // returns total number of spins
    int na(); // returns number of spins
    int nb(); // returns number of spins
    int nc(); // returns number of spins
    void invert();// inverts all spins

    void print(FILE * fout);
    int  load(FILE * fin_coq);	
     
    
    mfcf & operator= (const mfcf & op2); // zuweisung

   
   mfcf (const mfcf & spins);	// kopier-konstruktor
   

};

#endif