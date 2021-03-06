/*-----------------------------------------------------------------------------*\
| double precision complex  matrix multiplication                    cmatmul.cc |
|                                                                               |
| MatPack Library Release 1.0                                                   |
| Copyright (C) 1991-1996 by Berndt M. Gammel                                   |
|                                                                               |
| Permission to  use, copy, and  distribute  Matpack  in  its entirety  and its |
| documentation  for non-commercial purpose and  without fee is hereby granted, |
| provided that this license information and copyright notice appear unmodified |
| in all copies.  This software is provided 'as is'  without express or implied |
| warranty.  In no event will the author be held liable for any damages arising |
| from the use of this software.						|
| Note that distributing Matpack 'bundled' in with any product is considered to |
| be a 'commercial purpose'.							|
| The software may be modified for your own purposes, but modified versions may |
| not be distributed without prior consent of the author.			|
|                                                                               |
| Read the  COPYRIGHT and  README files in this distribution about registration	|
| and installation of Matpack.							|
|                                                                               |
\*-----------------------------------------------------------------------------*/

#include "vector.h"
#include "vecinl.h"

#ifdef _MATPACK_USE_BLAS_
#include "blas.h"
#endif

//----------------------------------------------------------------------------//
// macros to make the notation more concise
//----------------------------------------------------------------------------//

#define UT(A) (A.attribute == UpperTriangular)
#define LT(A) (A.attribute == LowerTriangular)
#define GM(A)  (A.attribute == General)

const complex<double> Zero(0.0,0.0);

//static const char *NonSquareMatrix  = "non square complex matrix";


//inline void checksquare (const ComplexMatrix& M)
//{
//    if (M.Rlo() != M.Clo() || M.Rhi() != M.Chi()) Matpack.Error(NonSquareMatrix);
//}

//----------------------------------------------------------------------------//
// complex matrix * complex matrix multiplication
//----------------------------------------------------------------------------//

ComplexMatrix operator * (const ComplexMatrix& A, const ComplexMatrix& B)
{
    if (A.Clo() != B.Rlo() || A.Chi() != B.Rhi()) 
      Matpack.Error("ComplexMatrix operator * (const ComplexMatrix&, const ComplexMatrix&): "
		    "non conformant arguments\n");
    
    // allocate return matrix
    ComplexMatrix C(A.Rlo(),A.Rhi(),B.Clo(),B.Chi());
    
    //------------------------------------------------------------------------//
    // the BLAS version
    //------------------------------------------------------------------------//

#if defined ( _MATPACK_USE_BLAS_ )

    if ( LT(B) ) {                   // full matrix * lower triangle
#ifdef DEBUG
//	cout << "GM*LT\n";
#endif
	checksquare(B);

	// copy A to C to protect from overwriting
	copyvec(C.Store(),A.Store(),A.Elements());

	charT     side('L'), uplo('U'), transc('N'), diag('N');
	intT      m(C.Cols()), n(C.Rows()),
	          ldb(B.Cols()), ldc(C.Cols());
	dcomplexT alpha(1.0);
	
	F77NAME(ztrmm)(&side,&uplo,&transc,&diag,&m,&n,
		       &alpha,B.Store(),&ldb, C.Store(),&ldc);


    } else if ( UT(B) ) {             // full matrix * upper triangle
#ifdef DEBUG
//	cout << "GM*UT\n";
#endif
	checksquare(B);

	// copy A to C to protect from overwriting
	copyvec(C.Store(),A.Store(),A.Elements());

	charT     side('L'), uplo('L'), transc('N'), diag('N');
	intT      m(C.Cols()), n(C.Rows()),
	          ldb(B.Cols()), ldc(C.Cols());
	dcomplexT alpha(1.0);
	
	F77NAME(ztrmm)(&side,&uplo,&transc,&diag,&m,&n,
		       &alpha,B.Store(),&ldb, C.Store(),&ldc);


    } else if ( LT(A) ) {            // lower triangle * full matrix
#ifdef DEBUG
//	cout << "LT*GM\n";
#endif

	checksquare(A);

	// copy B to C to protect from overwriting
	copyvec(C.Store(),B.Store(),B.Elements());

	charT     side('R'), uplo('U'), transc('N'), diag('N');
	intT      m(C.Cols()), n(C.Rows()),
	          ldb(A.Cols()), ldc(C.Cols());
	dcomplexT alpha(1.0);
	
	F77NAME(ztrmm)(&side,&uplo,&transc,&diag,&m,&n,
		       &alpha,A.Store(),&ldb, C.Store(),&ldc);



    } else if ( UT(A) ) {            // upper triangle * full matrix
#ifdef DEBUG
//	cout << "UT*GM\n";
#endif
	checksquare(A);

	// copy A to C to protect from overwriting
	copyvec(C.Store(),B.Store(),B.Elements());

	charT     side('R'), uplo('L'), transc('N'), diag('N');
	intT      m(C.Cols()), n(C.Rows()),
	          ldb(A.Cols()), ldc(C.Cols());
	dcomplexT alpha(1.0);
	
	F77NAME(ztrmm)(&side,&uplo,&transc,&diag,&m,&n,
		       &alpha,A.Store(),&ldb, C.Store(),&ldc);

    } else /* GM(A) and GM(B) */ {   // GM*GM: full matrix * full matrix
#ifdef DEBUG
//	cout << "GM*GM\n";
#endif

	charT     t('N');
	intT      m(B.Cols()), n(A.Rows()), k(B.Rows()),
	          lda(A.Cols()), ldb(B.Cols()), ldc(C.Cols());
	dcomplexT alpha(1.0), beta(0.0);
	
	F77NAME(zgemm)(&t,&t, &m,&n,&k,
		       &alpha,B.Store(),&ldb, A.Store(),&lda, 
		       &beta,C.Store(),&ldc);

    }

    //------------------------------------------------------------------------//
    // the non-BLAS version
    //------------------------------------------------------------------------//

#else 

    int  cl = A.cl,   ch = A.ch,
        arl = A.rl,  arh = A.rh,
        bcl = B.cl,  bch = B.ch;

    complex<double> **a = A.M+A.rl;
    complex<double> **b = B.M+B.rl;
    complex<double> **c = C.M+C.rl;
    int rsize  = A.nrow;
    int nsize;
    complex<double> *ap,*aa,**bb,**bp,*cp,sum;
    int n,col;
    
    if ( LT(B) ) {                   // full matrix * lower triangle
#ifdef DEBUG
//	cout << "GM*LT\n";
#endif

	checksquare(B);

	while (rsize--) {
	    cp = *c++ + C.cl;
	    aa = *a++ + A.cl;
	    bb = b;
	    nsize = A.ncol;
	    for (col = B.cl; col <= B.ch; col++) {
		ap = aa++;
		bp = bb++;
		n = nsize--;
		sum = 0;
		while (n--) sum += *ap++ * (*bp++)[col];
		*cp++ = sum;
	    }
	}

    } else if ( UT(B) ) {             // full matrix * upper triangle
#ifdef DEBUG
//	cout << "GM*UT\n";
#endif

	checksquare(B);

	while (rsize--) {
	    cp = *c++ + C.cl;
	    aa = *a++ + A.cl;
	    nsize = 1;
	    for (col = B.cl; col <= B.ch; col++) {
		ap = aa;
		bp = b;
		n = nsize++;
		sum = 0;
		while (n--) sum += *ap++ * (*bp++)[col];
		*cp++ = sum;
	    }
	}

    } else if ( LT(A) ) {            // lower triangle * full matrix
#ifdef DEBUG
//	cout << "LT*GM\n";
#endif
	checksquare(A);

	nsize = 1;
	while (rsize--) {
	    cp = *c++ + C.cl;
	    aa = *a++ + A.cl;
	    for (col = B.cl; col <= B.ch; col++) {
		ap = aa;
		bp = b;
		n = nsize;
		sum = 0;
		while (n--) sum += *ap++ * (*bp++)[col];
		*cp++ = sum;
	    }
	    nsize++;
	}


    } else if ( UT(A) ) {            // upper triangle * full matrix
#ifdef DEBUG
//	cout << "UT*GM\n";
#endif
	checksquare(A);

	nsize = A.ncol;
	int k = 0;
	while (rsize--) {
	    cp = *c++ + C.cl;
	    aa = *a++ + A.cl + k;
	    bb = b + k;
	    for (col = B.cl; col <= B.ch; col++) {
		ap = aa;
		bp = bb;
		n = nsize;
		sum = 0;
		while (n--) sum += *ap++ * (*bp++)[col];
		*cp++ = sum;
	    }
	    nsize--;
	    k++;
	}
	
    } else /* GM(A) and GM(B) */ {   // GM*GM: full matrix * full matrix

#ifdef DEBUG
//	cout << "GM*GM\n";
#endif
	// avoid call to index operator that optimizes very badely
	complex<double> **a = A.M, **b = B.M, **c = C.M;
	for (int i = arl; i <= arh; i++)  {
	    for (int j = bcl; j <= bch; j++) c[i][j] = Zero;	    
	    for (int l = cl; l <= ch; l++) {
		if (a[i][l] != Zero) {
		    const complex<double>& temp = a[i][l];
		    for (int j = bcl; j <= bch; j++)
		      c[i][j] += temp * b[l][j];
		}
	    }
	}
	
    }
#endif

    return C.Value();
} 

//----------------------------------------------------------------------------//
