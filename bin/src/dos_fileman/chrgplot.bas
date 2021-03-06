DECLARE SUB prtewuevfile (en#(), cr#(), cc#(), j!, n!)
DECLARE SUB cfhamnew (j!, gJ!, b#(), hx!, hy!, hz!, hr#(), hc#())
DECLARE SUB erww (hr#(), hc#(), d%, n%, en#(), cr#(), cc#(), tew#)
DECLARE SUB viewmatrix (ar#(), ac#(), row%, col%, text$)
DECLARE SUB cf (selfcon%, T!, qex#(), veff#(), en#(), cr#(), cc#(), j!, gJ!, b#(), hx!, hy!, hz!, dpxy!, dpxz!, dpyz!, hr#(), hc#())
DECLARE SUB inputline (n!, d1#(), col1%, d2$(), col2%)
DECLARE SUB headerinput (text$(), j!, n!)
DECLARE SUB rocalc (ro!, teta!, fi!, R!, a!(), cnst())
DECLARE SUB plot (a!(), cnst())
DECLARE SUB htribk (NM%, n%, ar#(), ai#(), tau#(), m%, zr#(), ZI#())
DECLARE SUB htridi (NM%, n%, ar#(), ai#(), d#(), E#(), E2#(), tau#())
DECLARE SUB imtql2 (NM%, n%, d#(), E#(), z#(), Ierr%)
DECLARE SUB prtewuev (en#(), cr#(), cc#(), j!)
DECLARE SUB termerww (hr#(), hc#(), d%, T, en#(), cr#(), cc#(), tew#)
DECLARE SUB diagonalize (hr#(), hc#(), rang%, en#(), cr#(), cc#())
DECLARE FUNCTION delta (x)
DECLARE FUNCTION multr# (ar#, ac#, br#, bc#)
DECLARE FUNCTION divc# (ar#, ac#, br#, bc#)
DECLARE FUNCTION divr# (ar#, ac#, br#, bc#)
DECLARE FUNCTION multc# (ar#, ac#, br#, bc#)

DIM hr#(20, 20), hc#(30, 30), cr#(20, 20), cc#(20, 20), temp(10)
DIM er#(20, 20), ec#(20, 20), d1#(20), meanfield(10), veff#(6, -6 TO 6)
DIM b#(6, -6 TO 6), en#(100), nul#(6, -6 TO 6), qex#(6, 6)
DIM a(6, -6 TO 6), tetan(6), cnst(6, -6 TO 6), txt$(20), d2$(10)
DIM par(40), parstp(40), parmin(40), parmax(40), parerr(40), PARTT$(40)
DIM parsav(40), parav(40)
   FOR l = 2 TO 6 STEP 2: FOR m = 0 TO l STEP 1
    READ cnst(l, m)
    cnst(l, -m) = cnst(l, m)
    DATA 0.3153962,1.092548,0.5462823
    DATA 0.1057871,0.6690465,0.4730943,1.77013,0.625845
    DATA 0.06357014,1.032669,0.4606094,0.921205,0.5045723,2.366619,0.6831942
   NEXT m: NEXT l
OPEN "o", 9, "chrgplot.log"
REM*************************************************** eingabedaten ********************************
PRINT "Program for Calculation of Charge Density Distribution of "
PRINT "Rare Earth Ions in a Crystal Field"
PRINT "parameters have to be given accordingly in file cf.par"
REM**************************************************************************
selfcon% = 0: 'selfconsistent calculation of quadrupolar exchange
programpath$ = ".\"
mb# = 5.788378E-02: REM Bohrmagneton in meV/tesla

infile$ = "cf.par"
'load parameters + stepwidths and range
OPEN "i", 1, programpath$ + infile$
CALL headerinput(txt$(), txt, 1): noofpar% = 0
WHILE EOF(1) = 0: CALL inputline(1, d1#(), col1%, d2$(), col2%)
'IF col1% > 1 THEN
 noofpar% = noofpar% + 1
 par(noofpar%) = d1#(1): parerr(noofpar%) = d1#(2): parstp(noofpar%) = d1#(2)
 parmin(noofpar%) = d1#(3): parmax(noofpar%) = d1#(4): PARTT$(noofpar%) = LCASE$(d2$(1))
'END IF
WEND: CLOSE 1

FOR DDD% = 1 TO noofpar%
IF PARTT$(DDD%) = "ce3+" THEN ION$ = PARTT$(DDD%): site% = 1: j = 5 / 2: gJ = 6 / 7' drehimpulsquantenzahl J,landefaktor gj ce3+
IF PARTT$(DDD%) = "nd3+" THEN ION$ = PARTT$(DDD%): site% = 2: j = 9 / 2: gJ = 8 / 11' drehimpulsquantenzahl J,landefaktor gj nd3+
IF PARTT$(DDD%) = "er3+" THEN ION$ = PARTT$(DDD%): site% = 3: j = 15 / 2: gJ = 6 / 5' drehimpulsquantenzahl J,landefaktor gj er3+
IF PARTT$(DDD%) = "tm3+" THEN ION$ = PARTT$(DDD%): site% = 4: j = 6: gJ = 7 / 6'drehimpulsquantenzahl J,landefaktor gj tm3+
IF PARTT$(DDD%) = "pr3+" THEN ION$ = PARTT$(DDD%): site% = 5: j = 4: gJ = 4 / 5' drehimpulsquantenzahl J,landefaktor gj pr3+
IF PARTT$(DDD%) = "tb3+" THEN ION$ = PARTT$(DDD%): site% = 6: j = 6: gJ = 3 / 2' drehimpulsquantenzahl J,landefaktor gj pr3+
IF PARTT$(DDD%) = "u3+" THEN ION$ = PARTT$(DDD%): site% = 7: j = 4: gJ = 4 / 5' drehimpulsquantenzahl J,landefaktor gj pr3+
IF PARTT$(DDD%) = "ho3+" THEN ION$ = PARTT$(DDD%): site% = 8: j = 8: gJ = 5 / 4' drehimpulsquantenzahl J,landefaktor gj pr3+
IF PARTT$(DDD%) = "dy3+" THEN ION$ = PARTT$(DDD%): site% = 9: j = 15 / 2: gJ = 4 / 3' drehimpulsquantenzahl J,landefaktor gj pr3+
NEXT DDD%
IF site% = 0 THEN PRINT "Error program ChrgPlot: ion "; ION$; " not implemented": END

IF site% = 1 THEN alpha = -2 / (5 * 7): beta = 2 / 9 / 5 / 7: gamma = 0: REM ce3+
IF site% = 2 THEN alpha = -7 / (9 * 121): beta = -8 * 17 / 27 / 11 / 121 / 13: gamma = -5 * 17 * 19 / 81 / 77 / 121 / 13 / 13: REM Nd3+
IF site% = 3 THEN alpha = 4 / (9 * 25 * 7): beta = 2 / 9 / 35 / 11 / 13: gamma = 8 / 27 / 7 / 121 / 13 / 13: REM er3+
IF site% = 4 THEN alpha = 1 / (9 * 11): beta = 8 / 81 / 5 / 121: gamma = -5 / 81 / 7 / 121 / 13: REM tm3+
IF site% = 5 THEN alpha = -4 * 13 / (9 * 25 * 11): beta = -4 / (9 * 5 * 121): gamma = 16 * 17 / 81 / 5 / 7 / 121 / 13: REM pr3+
IF site% = 6 THEN alpha = -1 / 99: beta = 2 / (27 * 5 * 121): gamma = -1 / 81 / 7 / 121 / 13: REM Tb3+ values from HUTCHINGS
IF site% = 7 THEN alpha = -4 * 13 / (9 * 25 * 11): beta = -4 / (9 * 5 * 121): gamma = 16 * 17 / 81 / 5 / 7 / 121 / 13: REM up3+
IF site% = 8 THEN alpha = -1 / 2 / 9 / 25: beta = -1 / 2 / 3 / 5 / 7 / 11 / 13: gamma = -5 / 27 / 7 / 121 / 13 / 13 'ho3+
IF site% = 9 THEN alpha = -2 / 9 / 5 / 7: beta = -8 / 27 / 5 / 7 / 11 / 13: gamma = 4 / 27 / 7 / 121 / 13 / 13 'dy3+

PRINT ION$
PRINT "J="; j
PRINT "gJ="; gJ
PRINT alpha; "{alpha Stevens factor}"
PRINT beta; "{beta Stevens factor}"
PRINT gamma; "{gamma Stevens factor}"

PRINT #9, ION$
PRINT #9, "J="; j
PRINT #9, "gJ="; gJ
PRINT #9, alpha; "{alpha Stevens factor}"
PRINT #9, beta; "{beta Stevens factor}"
PRINT #9, gamma; "{gamma Stevens factor}"

FOR DDD% = 1 TO noofpar%
 IF INSTR(PARTT$(DDD%), "b20") = 1 THEN b#(2, 0) = par(DDD%)
 IF INSTR(PARTT$(DDD%), "b22") = 1 THEN b#(2, 2) = par(DDD%)
 IF INSTR(PARTT$(DDD%), "b40") = 1 THEN b#(4, 0) = par(DDD%)
 IF INSTR(PARTT$(DDD%), "b42") = 1 THEN b#(4, 2) = par(DDD%)
 IF INSTR(PARTT$(DDD%), "b44") = 1 THEN b#(4, 4) = par(DDD%)
 IF INSTR(PARTT$(DDD%), "b60") = 1 THEN b#(6, 0) = par(DDD%)
 IF INSTR(PARTT$(DDD%), "b62") = 1 THEN b#(6, 2) = par(DDD%)
 IF INSTR(PARTT$(DDD%), "b64") = 1 THEN b#(6, 4) = par(DDD%)
 IF INSTR(PARTT$(DDD%), "b66") = 1 THEN b#(6, 6) = par(DDD%)

 IF INSTR(PARTT$(DDD%), "v20") = 1 THEN b#(2, 0) = par(DDD%) * alpha
 IF INSTR(PARTT$(DDD%), "v22") = 1 THEN b#(2, 2) = par(DDD%) * alpha
 IF INSTR(PARTT$(DDD%), "v40") = 1 THEN b#(4, 0) = par(DDD%) * beta
 IF INSTR(PARTT$(DDD%), "v42") = 1 THEN b#(4, 2) = par(DDD%) * beta
 IF INSTR(PARTT$(DDD%), "v44") = 1 THEN b#(4, 4) = par(DDD%) * beta
 IF INSTR(PARTT$(DDD%), "v60") = 1 THEN b#(6, 0) = par(DDD%) * gamma
 IF INSTR(PARTT$(DDD%), "v62") = 1 THEN b#(6, 2) = par(DDD%) * gamma
 IF INSTR(PARTT$(DDD%), "v64") = 1 THEN b#(6, 4) = par(DDD%) * gamma
 IF INSTR(PARTT$(DDD%), "v66") = 1 THEN b#(6, 6) = par(DDD%) * gamma
 
 IF INSTR(PARTT$(DDD%), "o20-q-exchange") = 1 THEN qex#(2, 0) = par(DDD%)
 IF INSTR(PARTT$(DDD%), "o22-q-exchange") = 1 THEN qex#(2, 2) = par(DDD%)
 IF INSTR(PARTT$(DDD%), "o40-q-exchange") = 1 THEN qex#(4, 0) = par(DDD%)
 IF INSTR(PARTT$(DDD%), "o42-q-exchange") = 1 THEN qex#(4, 2) = par(DDD%)
 IF INSTR(PARTT$(DDD%), "o44-q-exchange") = 1 THEN qex#(4, 4) = par(DDD%)
 IF INSTR(PARTT$(DDD%), "o60-q-exchange") = 1 THEN qex#(6, 0) = par(DDD%)
 IF INSTR(PARTT$(DDD%), "o62-q-exchange") = 1 THEN qex#(6, 2) = par(DDD%)
 IF INSTR(PARTT$(DDD%), "o64-q-exchange") = 1 THEN qex#(6, 4) = par(DDD%)
 IF INSTR(PARTT$(DDD%), "o66-q-exchange") = 1 THEN qex#(6, 6) = par(DDD%)
NEXT DDD%
PRINT USING "B20=###.###^^^^meV    V20=###.###^^^^meV"; b#(2, 0); b#(2, 0) / alpha
PRINT USING "B22=###.###^^^^meV    V22=###.###^^^^meV"; b#(2, 2); b#(2, 2) / alpha
PRINT USING "B40=###.###^^^^meV    V40=###.###^^^^meV"; b#(4, 0); b#(4, 0) / beta
PRINT USING "B42=###.###^^^^meV    V42=###.###^^^^meV"; b#(4, 2); b#(4, 2) / beta
PRINT USING "B44=###.###^^^^meV    V44=###.###^^^^meV"; b#(4, 4); b#(4, 4) / beta

PRINT #9, USING "B20=###.###^^^^meV    V20=###.###^^^^meV"; b#(2, 0); b#(2, 0) / alpha
PRINT #9, USING "B22=###.###^^^^meV    V22=###.###^^^^meV"; b#(2, 2); b#(2, 2) / alpha
PRINT #9, USING "B40=###.###^^^^meV    V40=###.###^^^^meV"; b#(4, 0); b#(4, 0) / beta
PRINT #9, USING "B42=###.###^^^^meV    V42=###.###^^^^meV"; b#(4, 2); b#(4, 2) / beta
PRINT #9, USING "B44=###.###^^^^meV    V44=###.###^^^^meV"; b#(4, 4); b#(4, 4) / beta
 IF gamma <> 0 THEN

PRINT USING "B60=###.###^^^^meV    V60=###.###^^^^meV"; b#(6, 0); b#(6, 0) / gamma
PRINT USING "B62=###.###^^^^meV    V62=###.###^^^^meV"; b#(6, 2); b#(6, 2) / gamma
PRINT USING "B64=###.###^^^^meV    V64=###.###^^^^meV"; b#(6, 4); b#(6, 4) / gamma
PRINT USING "B66=###.###^^^^meV    V66=###.###^^^^meV"; b#(6, 6); b#(6, 6) / gamma

PRINT #9, USING "B60=###.###^^^^meV    V60=###.###^^^^meV"; b#(6, 0); b#(6, 0) / gamma
PRINT #9, USING "B62=###.###^^^^meV    V62=###.###^^^^meV"; b#(6, 2); b#(6, 2) / gamma
PRINT #9, USING "B64=###.###^^^^meV    V64=###.###^^^^meV"; b#(6, 4); b#(6, 4) / gamma
PRINT #9, USING "B66=###.###^^^^meV    V66=###.###^^^^meV"; b#(6, 6); b#(6, 6) / gamma

 END IF

   tetan(2) = alpha: tetan(4) = beta: tetan(6) = gamma

325 INPUT "selfconsisten calculation of charge density (1/0)<0>"; selfcon%

PRINT #9, "selcfonsistent calculation of charge density: "; selfcon%
PRINT "temperatur<"; T; "K>"; : INPUT ala$: IF ala$ <> "" THEN T = VAL(ala$)
PRINT "h||x<"; hx; "T>"; : INPUT ala$: IF ala$ <> "" THEN hx = VAL(ala$)
PRINT "h||y<"; hy; "T>"; : INPUT ala$: IF ala$ <> "" THEN hy = VAL(ala$)
PRINT "h||z<"; hz; "T>"; : INPUT ala$: IF ala$ <> "" THEN hz = VAL(ala$)

PRINT #9, USING "T=###.###K Hx=###.###T  Hy=###.###T  Hz=###.###T "; T; hx; hy; hz

CALL cf(selfcon%, T, qex#(), veff#(), en#(), cr#(), cc#(), j, gJ, b#(), hx, hy, hz, dpxy, dpxz, dpyz, hr#(), hc#())
CALL prtewuev(en#(), cr#(), cc#(), j)

 
  a(0, 0) = 1 / SQR(4 * 3.1415)
  PRINT "chargedensity for state number (1 to 2*J+1="; 2 * j + 1; ")"
  PRINT "note: degenerate states will be summed up !"
  PRINT "(0 means thermal expectation value) <"; statenumber%; ">"; : INPUT ala$
  IF ala$ <> "" THEN statenumber% = VAL(ala$)
  IF statenumber < 0 OR statenumber% > 2 * j + 1 THEN PRINT "error - statenumber out of range": END
 
 
  PRINT #9, "chargedensity for state number "; statenumber%; " (1 to 2*J+1="; 2 * j + 1; ") - 0 means thermal expectation value"

FOR l = 2 TO 6 STEP 2: FOR m = -l TO l
nul#(l, m) = 1
CALL cfhamnew(j, gJ, nul#(), 0, 0, 0, er#(), ec#())
'ala$ = "O" + STR$(l) + STR$(m)
'CALL viewmatrix(er#(), ec#(), 2 * j + 1, 2 * j + 1, ala$)

IF statenumber% = 0 THEN
  CALL termerww(er#(), ec#(), 2 * j + 1, T, en#(), cr#(), cc#(), ht#)
ELSE
  CALL erww(er#(), ec#(), 2 * j + 1, statenumber%, en#(), cr#(), cc#(), ht#)
  
END IF

nul#(l, m) = 0
a(l, m) = ht#
NEXT m: NEXT l

PRINT "thermal expectation value of Olms"
PRINT #9, "thermal expectation value of Olms"
FOR l = 2 TO 6 STEP 2: FOR m = -l TO l
PRINT USING "O## ##=##.###^^^^ "; l, m, a(l, m);
PRINT #9, USING "O## ##=##.###^^^^ "; l, m, a(l, m);
a(l, m) = a(l, m) * tetan(l) * cnst(l, m)
NEXT m: PRINT : PRINT #9, : NEXT l
  
PRINT "expansion coefficients for charge density"
PRINT #9, "expansion coefficients for charge density"
FOR l = 2 TO 6 STEP 2: FOR m = -l TO l
PRINT USING "coefficient## ## ##.###^^^^ "; l, m, a(l, m);
PRINT #9, USING "coefficient## ## ##.###^^^^ "; l, m, a(l, m);
a(l, m) = a(l, m) * 1
NEXT m: PRINT : PRINT #9, : NEXT l

 CALL plot(a(), cnst())
INPUT "another t-h point (y/n)"; ala$
IF ala$ = "y" GOTO 325
CLOSE 9
PRINT "view geometry files with: java javaview *.jvx"
END

SUB cf (selfcon%, T, qex#(), veff#(), en#(), cr#(), cc#(), j, gJ, b#(), hx, hy, hz, dpxy, dpxz, dpyz, hr#(), hc#())
STATIC washere%
STATIC mat20r#(), mat22r#(), mat40r#(), mat42r#(), mat44r#(), mat60r#(), mat62r#(), mat64r#(), mat66r#()
STATIC mat20c#(), mat22c#(), mat40c#(), mat42c#(), mat44c#(), mat60c#(), mat62c#(), mat64c#(), mat66c#()
' sub to calculate for a given T and field h the
' Cf matrix and parameters selfconsistently ... including
' the quadrupolar exchange given by qex#()
DIM olm#(6, -6 TO 6)
DIM null#(6, -6 TO 6)
                      
IF washere% = 0 THEN
 washere% = 1
DIM mat20r#(2 * j + 1, 2 * j + 1)
DIM mat20c#(2 * j + 1, 2 * j + 1)
DIM mat22r#(2 * j + 1, 2 * j + 1)
DIM mat22c#(2 * j + 1, 2 * j + 1)
DIM mat40r#(2 * j + 1, 2 * j + 1)
DIM mat40c#(2 * j + 1, 2 * j + 1)
DIM mat42r#(2 * j + 1, 2 * j + 1)
DIM mat42c#(2 * j + 1, 2 * j + 1)
DIM mat44r#(2 * j + 1, 2 * j + 1)
DIM mat44c#(2 * j + 1, 2 * j + 1)
DIM mat60r#(2 * j + 1, 2 * j + 1)
DIM mat60c#(2 * j + 1, 2 * j + 1)
DIM mat62r#(2 * j + 1, 2 * j + 1)
DIM mat62c#(2 * j + 1, 2 * j + 1)
DIM mat64r#(2 * j + 1, 2 * j + 1)
DIM mat64c#(2 * j + 1, 2 * j + 1)
DIM mat66r#(2 * j + 1, 2 * j + 1)
DIM mat66c#(2 * j + 1, 2 * j + 1)
 ' initialize olm matrizes
 null#(2, 0) = 1: CALL cfhamnew(j, gJ, null#(), 0, 0, 0, mat20r#(), mat20c#()): null#(2, 0) = 0
 null#(2, 2) = 1: CALL cfhamnew(j, gJ, null#(), 0, 0, 0, mat22r#(), mat22c#()): null#(2, 2) = 0
 null#(4, 0) = 1: CALL cfhamnew(j, gJ, null#(), 0, 0, 0, mat40r#(), mat40c#()): null#(4, 0) = 0
 null#(4, 2) = 1: CALL cfhamnew(j, gJ, null#(), 0, 0, 0, mat42r#(), mat42c#()): null#(4, 2) = 0
 null#(4, 4) = 1: CALL cfhamnew(j, gJ, null#(), 0, 0, 0, mat44r#(), mat44c#()): null#(4, 4) = 0
 null#(6, 0) = 1: CALL cfhamnew(j, gJ, null#(), 0, 0, 0, mat60r#(), mat60c#()): null#(6, 0) = 0
 null#(6, 2) = 1: CALL cfhamnew(j, gJ, null#(), 0, 0, 0, mat62r#(), mat62c#()): null#(6, 2) = 0
 null#(6, 4) = 1: CALL cfhamnew(j, gJ, null#(), 0, 0, 0, mat64r#(), mat64c#()): null#(6, 4) = 0
 null#(6, 6) = 1: CALL cfhamnew(j, gJ, null#(), 0, 0, 0, mat66r#(), mat66c#()): null#(6, 6) = 0
 FOR l% = 2 TO 6 STEP 2
 FOR m% = 0 TO l% STEP 2
  veff#(l%, m%) = b#(l%, m%)
 NEXT: NEXT
END IF

'stabilize selfconsistent parameters veff#
sta = 1E+10
WHILE sta > 1E-17
 n% = n% + 1
         IF n% > 1000 THEN
          n% = 0       'reinitialize veff#()
           FOR l% = 2 TO 6 STEP 2: FOR m% = 0 TO l% STEP 2
            veff#(l%, m%) = b#(l%, m%) * 2 * (.5 - RND(1))
            PRINT USING "veff# #=##.####^^^^meV "; l%; m%; veff#(l%, m%);
            PRINT #9, USING "veff# #=##.####^^^^meV "; l%; m%; veff#(l%, m%);
           NEXT: PRINT : PRINT #9, : NEXT: PRINT : PRINT #9,
         END IF
 CALL cfhamnew(j, gJ, veff#(), hx, hy, hz, hr#(), hc#())
 CALL diagonalize(hr#(), hc#(), 2 * j + 1, en#(), cr#(), cc#())
    IF selfcon% = 0 GOTO 132
 CALL termerww(mat20r#(), mat20c#(), 2 * j + 1, T, en#(), cr#(), cc#(), olm#(2, 0))
 CALL termerww(mat22r#(), mat22c#(), 2 * j + 1, T, en#(), cr#(), cc#(), olm#(2, 2))
 CALL termerww(mat40r#(), mat40c#(), 2 * j + 1, T, en#(), cr#(), cc#(), olm#(4, 0))
 CALL termerww(mat42r#(), mat42c#(), 2 * j + 1, T, en#(), cr#(), cc#(), olm#(4, 2))
 CALL termerww(mat44r#(), mat44c#(), 2 * j + 1, T, en#(), cr#(), cc#(), olm#(4, 4))
 CALL termerww(mat60r#(), mat60c#(), 2 * j + 1, T, en#(), cr#(), cc#(), olm#(6, 0))
 CALL termerww(mat62r#(), mat62c#(), 2 * j + 1, T, en#(), cr#(), cc#(), olm#(6, 2))
 CALL termerww(mat64r#(), mat64c#(), 2 * j + 1, T, en#(), cr#(), cc#(), olm#(6, 4))
 CALL termerww(mat66r#(), mat66c#(), 2 * j + 1, T, en#(), cr#(), cc#(), olm#(6, 6))

 'calculate effective parameters
 sta = 0
 FOR l% = 2 TO 6 STEP 2
 FOR m% = 0 TO l% STEP 2
  vold# = veff#(l%, m%)
  veff#(l%, m%) = b#(l%, m%) + qex#(l%, m%) * olm#(l%, m%)
  sta = sta + (vold# - veff#(l%, m%)) * (vold# - veff#(l%, m%))
 NEXT: NEXT
WEND


132 END SUB

SUB cfhamnew (j, gJ, b#(), hx, hy, hz, hr#(), hc#())

 REM ********************************************************************
 REM diese routine dient zur berechnung des kristallfeldhamiltonoperators
 REM eingabe:
 REM J............drehimpulsquantenzahl
 REM gJ...........Landefaktor(nur fuer H<>0 von bedeutung
 REM vr#(l,m)......kristallfeldpar.in mev(implementier:l gerade,for l<=2 all,
 ' for l>2: m>0,m<>1,5)
 REM hx,hy,hz.....magnetfeld in tesla
 REM ausgabe:
 REM hr#(1..2J+1,1..2J+1),hc#(1..2J+1,1..2J+1)........real- und imaginaerteil
 REM der kristallfeldmatrix <m|Hcf+Hze|n>=hr#(m+J+1,n+J+1)+ihc#(m+J+1,n+J+1)
 REM ********************************************************************

 DIM o#(6, -6 TO 6)
 mb# = 5.788378E-02: REM Bohrmagneton in meV/tesla
' PRINT "m'= "; : FOR x = -j TO j: PRINT USING "###.##"; x; : NEXT x: PRINT
' PRINT "m= ";
 FOR x = -j TO j
' PRINT : PRINT USING "##.#"; x;
  FOR y = -j TO j

   REM addieren der einzelnen beitr�ge v(m,n).<J,x:o(m,n):J,y>
   hr#(x + j + 1, y + j + 1) = 0: hc#(x + j + 1, y + j + 1) = 0

   GOSUB 5000


'  IF ABS(hr#(x + j + 1, y + j + 1)) > .001 THEN PRINT USING "###.##"; hr#(x + j + 1, y + j + 1); :                     ELSE PRINT "  0   ";

  NEXT y
'  PRINT : PRINT "    ";
'  FOR y = -j TO j
'   IF ABS(hc#(x + j + 1, y + j + 1)) > .001 THEN PRINT " i"; : PRINT USING "##.#"; hc#(x + j + 1, y + j + 1); :                     ELSE PRINT "      ";
'  NEXT y
  NEXT x
' PRINT
 GOTO 281

5000 REM Berechnung von <Jx:o(m,n):Jy>=o#(m,n)
5010 REM f�r geringe Symmetrie sind eventuell zus�tzliche
5020 REM stevenson-Operatoren hier hinzuzuf�gen und am Programmanfang
5030 REM die entsprechenden b#(m,n) zu erg�nzen
5040 REM der gew�hnliche Ausdruck f�r einen Stevenson-op. wird hier
5050 REM so ver�ndert,dass direkt statt des operators jz entweder die
5060 REM zahl x od y bzw. statt j+ und j- entsprechende zahlen in der
5070 REM formel vorkommen.
5080 REM
 REM ********************************************************************
 REM berechnung der den potenzen von j+ und j- entsprechenden zahlen
 REM *****     Formeln f�r die Stevenson - Operatoren              ******
 REM                       Summation
 REM ********************************************************************
IF x = y THEN
 o#(2, 0) = (3 * x * x - j * (j + 1))
 o#(4, 0) = (35 * x * x * x * x - 30 * j * (j + 1) * x * x + 25 * x * x - 6 * j * (j + 1) + 3 * j * j * (j + 1) * (j + 1))
 o#(6, 0) = (231 * x * x * x * x * x * x - 315 * j * (j + 1) * x * x * x * x + 735 * x * x * x * x + 105 * j * j * (j + 1) * (j + 1) * x * x - 525 * j * (j + 1) * x * x + 294 * x * x - 5 * j * j * j * (j + 1) * (j + 1) * (j + 1) + 40 * j * j * (j +  _
1) * (j + 1) - 60 * j * (j + 1))
 FOR m = 2 TO 6 STEP 2
   hr#(x + j + 1, y + j + 1) = hr#(x + j + 1, y + j + 1) + b#(m, 0) * o#(m, 0)
    REM da in einem array nur positive argumente zugelassen sind, entspricht
    REM hcf(m,m')..HCF#(X+J+1,Y+J+1) mit x,y=m,m'!!!!!
 NEXT m
 REM Zeemannterm
  hr#(x + j + 1, y + j + 1) = hr#(x + j + 1, y + j + 1) - gJ * mb# * hz * x
END IF

IF x = y + 1 THEN
 JP1# = SQR((j - y) * (j + y + 1))
 Jx# = JP1# / 2: REM reell
 Jy# = -JP1# / 2: REM imaginaer
   REM Zeemannterm
     hr#(x + j + 1, y + j + 1) = hr#(x + j + 1, y + j + 1) - gJ * mb# * hx * Jx#
     hc#(x + j + 1, y + j + 1) = hc#(x + j + 1, y + j + 1) - gJ * mb# * hy * Jy#
   REM pxy,pxz,pyz
 o#(2, 1) = (x * Jx# + Jx# * y) / 2
 o#(2, -1) = (x * Jy# + Jy# * y) / 2
 o#(4, 1) = ((7 * x * x * x - x * 3 * j * (j + 1)) * JP1# + JP1# * (7 * y * y * y - y * 3 * j * (j + 1))) / 4
 o#(4, -1) = -((7 * x * x * x - x * 3 * j * (j + 1)) * JP1# + JP1# * (7 * y * y * y - y * 3 * j * (j + 1))) / 4
 o#(6, 1) = ((33 * x * x * x * x * x - x * x * x * (30 * j * (j + 1) - 15) + x * (5 * j * j * (j + 1) * (j + 1) - 10 * j * (j + 1) + 12)) * JP1# + JP1# * (33 * y * y * y * y * y - y * y * y * (30 * j * (j + 1) - 15) + y * (5 * j * j * (j + 1) * (j + _
 1) - 10 * j * (j + 1) + 12))) / 4
 o#(6, -1) = -((33 * x * x * x * x * x - x * x * x * (30 * j * (j + 1) - 15) + x * (5 * j * j * (j + 1) * (j + 1) - 10 * j * (j + 1) + 12)) * JP1# + JP1# * (33 * y * y * y * y * y - y * y * y * (30 * j * (j + 1) - 15) + y * (5 * j * j * (j + 1) * (j _
 + 1) - 10 * j * (j + 1) + 12))) / 4
   FOR m = 2 TO 6 STEP 2
     hr#(x + j + 1, y + j + 1) = hr#(x + j + 1, y + j + 1) + b#(m, 1) * o#(m, 1)
     hc#(x + j + 1, y + j + 1) = hc#(x + j + 1, y + j + 1) + b#(m, -1) * o#(m, -1)
   NEXT m
END IF

IF x = y - 1 THEN
 JM1# = SQR((j + y) * (j - y + 1))
 Jx# = JM1# / 2: REM reell
 Jy# = JM1# / 2: REM imaginaer
   REM Zeemannterm
     hr#(x + j + 1, y + j + 1) = hr#(x + j + 1, y + j + 1) - gJ * mb# * hx * Jx#
     hc#(x + j + 1, y + j + 1) = hc#(x + j + 1, y + j + 1) - gJ * mb# * hy * Jy#
   REM pxy,pxz,pyz
 o#(2, 1) = (x * Jx# + Jx# * y) / 2
 o#(2, -1) = (x * Jy# + Jy# * y) / 2
 o#(4, 1) = ((7 * x * x * x - x * 3 * j * (j + 1)) * JM1# + JM1# * (7 * y * y * y - y * 3 * j * (j + 1))) / 4
 o#(4, -1) = ((7 * x * x * x - x * 3 * j * (j + 1)) * JM1# + JM1# * (7 * y * y * y - y * 3 * j * (j + 1))) / 4
 o#(6, 1) = ((33 * x * x * x * x * x - x * x * x * (30 * j * (j + 1) - 15) + x * (5 * j * j * (j + 1) * (j + 1) - 10 * j * (j + 1) + 12)) * JM1# + JM1# * (33 * y * y * y * y * y - y * y * y * (30 * j * (j + 1) - 15) + y * (5 * j * j * (j + 1) * (j + _
 1) - 10 * j * (j + 1) + 12))) / 4
 o#(6, -1) = ((33 * x * x * x * x * x - x * x * x * (30 * j * (j + 1) - 15) + x * (5 * j * j * (j + 1) * (j + 1) - 10 * j * (j + 1) + 12)) * JM1# + JM1# * (33 * y * y * y * y * y - y * y * y * (30 * j * (j + 1) - 15) + y * (5 * j * j * (j + 1) * (j  _
+ 1) - 10 * j * (j + 1) + 12))) / 4
   FOR m = 2 TO 6 STEP 2
     hr#(x + j + 1, y + j + 1) = hr#(x + j + 1, y + j + 1) + b#(m, 1) * o#(m, 1)
     hc#(x + j + 1, y + j + 1) = hc#(x + j + 1, y + j + 1) + b#(m, -1) * o#(m, -1)
   NEXT m
END IF

IF x = y + 2 THEN
JP2# = SQR((j - y) * (j + y + 1) * (j - y - 1) * (j + y + 2))
   REM pxy
 o#(2, -2) = -JP2# / 2'imag
 o#(2, 2) = JP2# / 2
 o#(4, 2) = ((7 * x * x - j * (j + 1) - 5) * JP2# + JP2# * (7 * y * y - j * (j + 1) - 5)) / 4
 o#(4, -2) = -((7 * x * x - j * (j + 1) - 5) * JP2# + JP2# * (7 * y * y - j * (j + 1) - 5)) / 4
 o#(6, 2) = ((33 * x * x * x * x - (18 * j * (j + 1) + 123) * x * x + j * j * (j + 1) * (j + 1) + 10 * j * (j + 1) + 102) * JP2# + JP2# * (33 * y * y * y * y - (18 * j * (j + 1) + 123) * y * y + j * j * (j + 1) * (j + 1) + 10 * j * (j + 1) + 102)) / _
 4
 o#(6, -2) = -((33 * x * x * x * x - (18 * j * (j + 1) + 123) * x * x + j * j * (j + 1) * (j + 1) + 10 * j * (j + 1) + 102) * JP2# + JP2# * (33 * y * y * y * y - (18 * j * (j + 1) + 123) * y * y + j * j * (j + 1) * (j + 1) + 10 * j * (j + 1) + 102)) _
 / 4
   FOR m = 2 TO 6 STEP 2
    hr#(x + j + 1, y + j + 1) = hr#(x + j + 1, y + j + 1) + b#(m, 2) * o#(m, 2)
    hc#(x + j + 1, y + j + 1) = hc#(x + j + 1, y + j + 1) + b#(m, -2) * o#(m, -2)
    REM da in einem array nur positive argumente zugelassen sind, entspricht
    REM hcf(m,m')..HCF#(X+J+1,Y+J+1) mit x,y=m,m'!!!!!
   NEXT m
  END IF

IF x = y - 2 THEN
JM2# = SQR((j + y) * (j - y + 1) * (j + y - 1) * (j - y + 2))
   REM pxy
 o#(2, -2) = JM2# / 2  'imag
 o#(2, 2) = JM2# / 2
 o#(4, 2) = ((7 * x * x - j * (j + 1) - 5) * JM2# + JM2# * (7 * y * y - j * (j + 1) - 5)) / 4
 o#(4, -2) = ((7 * x * x - j * (j + 1) - 5) * JM2# + JM2# * (7 * y * y - j * (j + 1) - 5)) / 4
 o#(6, 2) = ((33 * x * x * x * x - (18 * j * (j + 1) + 123) * x * x + j * j * (j + 1) * (j + 1) + 10 * j * (j + 1) + 102) * JM2# + JM2# * (33 * y * y * y * y - (18 * j * (j + 1) + 123) * y * y + j * j * (j + 1) * (j + 1) + 10 * j * (j + 1) + 102)) / _
 4
 o#(6, -2) = ((33 * x * x * x * x - (18 * j * (j + 1) + 123) * x * x + j * j * (j + 1) * (j + 1) + 10 * j * (j + 1) + 102) * JM2# + JM2# * (33 * y * y * y * y - (18 * j * (j + 1) + 123) * y * y + j * j * (j + 1) * (j + 1) + 10 * j * (j + 1) + 102))  _
/ 4
   FOR m = 2 TO 6 STEP 2
    hr#(x + j + 1, y + j + 1) = hr#(x + j + 1, y + j + 1) + b#(m, 2) * o#(m, 2)
    hc#(x + j + 1, y + j + 1) = hc#(x + j + 1, y + j + 1) + b#(m, -2) * o#(m, -2)
    REM da in einem array nur positive argumente zugelassen sind, entspricht
    REM hcf(m,m')..HCF#(X+J+1,Y+J+1) mit x,y=m,m'!!!!!
   NEXT m
END IF

IF x = y + 3 THEN
JP3# = SQR((j - y) * (j - y - 1) * (j - y - 2) * (j + y + 1) * (j + y + 2) * (j + y + 3))
o#(4, 3) = (x * JP3# + JP3# * y) / 4 're
o#(4, -3) = -(x * JP3# + JP3# * y) / 4 'im
o#(6, 3) = ((11 * x * x * x - 3 * j * (j + 1) * x - 59 * x) * JP3# + JP3# * (11 * y * y * y - 3 * j * (j + 1) * y - 59 * y)) / 4
o#(6, -3) = -((11 * x * x * x - 3 * j * (j + 1) * x - 59 * x) * JP3# + JP3# * (11 * y * y * y - 3 * j * (j + 1) * y - 59 * y)) / 4
 hr#(x + j + 1, y + j + 1) = hr#(x + j + 1, y + j + 1) + b#(4, 3) * o#(4, 3)
 hc#(x + j + 1, y + j + 1) = hc#(x + j + 1, y + j + 1) + b#(4, -3) * o#(4, -3)
 hr#(x + j + 1, y + j + 1) = hr#(x + j + 1, y + j + 1) + b#(6, 3) * o#(6, 3)
 hc#(x + j + 1, y + j + 1) = hc#(x + j + 1, y + j + 1) + b#(6, -3) * o#(6, -3)
END IF

IF x = y - 3 THEN
JM3# = SQR((j + y) * (j + y - 1) * (j + y - 2) * (j - y + 1) * (j - y + 2) * (j - y + 3))
o#(4, 3) = (x * JM3# + JM3# * y) / 4     're
o#(4, -3) = (x * JM3# + JM3# * y) / 4 'im
o#(6, 3) = ((11 * x * x * x - 3 * j * (j + 1) * x - 59 * x) * JM3# + JM3# * (11 * y * y * y - 3 * j * (j + 1) * y - 59 * y)) / 4
o#(6, -3) = ((11 * x * x * x - 3 * j * (j + 1) * x - 59 * x) * JM3# + JM3# * (11 * y * y * y - 3 * j * (j + 1) * y - 59 * y)) / 4
 hr#(x + j + 1, y + j + 1) = hr#(x + j + 1, y + j + 1) + b#(4, 3) * o#(4, 3)
 hc#(x + j + 1, y + j + 1) = hc#(x + j + 1, y + j + 1) + b#(4, -3) * o#(4, -3)
 hr#(x + j + 1, y + j + 1) = hr#(x + j + 1, y + j + 1) + b#(6, 3) * o#(6, 3)
 hc#(x + j + 1, y + j + 1) = hc#(x + j + 1, y + j + 1) + b#(6, -3) * o#(6, -3)
END IF

IF x = y + 4 THEN
JP4# = SQR((j - y) * (j - y - 1) * (j - y - 2) * (j - y - 3) * (j + y + 1) * (j + y + 2) * (j + y + 3) * (j + y + 4))
 o#(4, 4) = JP4# / 2 're
 o#(4, -4) = -JP4# / 2  'im
 o#(6, 4) = ((11 * x * x - j * (j + 1) - 38) * JP4# + JP4# * (11 * y * y - j * (j + 1) - 38)) / 4
 o#(6, -4) = -((11 * x * x - j * (j + 1) - 38) * JP4# + JP4# * (11 * y * y - j * (j + 1) - 38)) / 4
  hr#(x + j + 1, y + j + 1) = hr#(x + j + 1, y + j + 1) + b#(4, 4) * o#(4, 4)
  hc#(x + j + 1, y + j + 1) = hc#(x + j + 1, y + j + 1) + b#(4, -4) * o#(4, -4)
  hr#(x + j + 1, y + j + 1) = hr#(x + j + 1, y + j + 1) + b#(6, 4) * o#(6, 4)
  hc#(x + j + 1, y + j + 1) = hc#(x + j + 1, y + j + 1) + b#(6, -4) * o#(6, -4)
END IF

IF x = y - 4 THEN
JM4# = SQR((j + y) * (j + y - 1) * (j + y - 2) * (j + y - 3) * (j - y + 1) * (j - y + 2) * (j - y + 3) * (j - y + 4))
 o#(4, 4) = JM4# / 2 're
 o#(4, -4) = JM4# / 2 'im
 o#(6, 4) = ((11 * x * x - j * (j + 1) - 38) * JM4# + JM4# * (11 * y * y - j * (j + 1) - 38)) / 4
 o#(6, -4) = ((11 * x * x - j * (j + 1) - 38) * JM4# + JM4# * (11 * y * y - j * (j + 1) - 38)) / 4
  hr#(x + j + 1, y + j + 1) = hr#(x + j + 1, y + j + 1) + b#(4, 4) * o#(4, 4)
  hc#(x + j + 1, y + j + 1) = hc#(x + j + 1, y + j + 1) + b#(4, -4) * o#(4, -4)
  hr#(x + j + 1, y + j + 1) = hr#(x + j + 1, y + j + 1) + b#(6, 4) * o#(6, 4)
  hc#(x + j + 1, y + j + 1) = hc#(x + j + 1, y + j + 1) + b#(6, -4) * o#(6, -4)
END IF

IF x = y + 5 THEN
JP5# = SQR((j - y) * (j - y - 1) * (j - y - 2) * (j - y - 3) * (j - y - 4) * (j + y + 1) * (j + y + 2) * (j + y + 3) * (j + y + 4) * (j + y + 5))
 o#(6, 5) = (x * JP5# + JP5# * y) / 4
 o#(6, -5) = -(x * JP5# + JP5# * y) / 4
  hr#(x + j + 1, y + j + 1) = hr#(x + j + 1, y + j + 1) + b#(6, 5) * o#(6, 5)
  hc#(x + j + 1, y + j + 1) = hc#(x + j + 1, y + j + 1) + b#(6, -5) * o#(6, -5)
END IF

IF x = y - 5 THEN
JM5# = SQR((j + y) * (j + y - 1) * (j + y - 2) * (j + y - 3) * (j + y - 4) * (j - y + 1) * (j - y + 2) * (j - y + 3) * (j - y + 4) * (j - y + 5))
 o#(6, 5) = (x * JM5# + JM5# * y) / 4
 o#(6, -5) = (x * JM5# + JM5# * y) / 4
  hr#(x + j + 1, y + j + 1) = hr#(x + j + 1, y + j + 1) + b#(6, 5) * o#(6, 5)
  hc#(x + j + 1, y + j + 1) = hc#(x + j + 1, y + j + 1) + b#(6, -5) * o#(6, -5)
END IF

IF x = y + 6 THEN
JP6# = SQR((j - y) * (j - y - 1) * (j - y - 2) * (j - y - 3) * (j - y - 4) * (j - y - 5) * (j + y + 1) * (j + y + 2) * (j + y + 3) * (j + y + 4) * (j + y + 5) * (j + y + 6))
 o#(6, 6) = JP6# / 2
 o#(6, -6) = -JP6# / 2 'im
  hr#(x + j + 1, y + j + 1) = hr#(x + j + 1, y + j + 1) + b#(6, 6) * o#(6, 6)
  hc#(x + j + 1, y + j + 1) = hc#(x + j + 1, y + j + 1) + b#(6, -6) * o#(6, -6)
END IF

IF x = y - 6 THEN
JM6# = SQR((j + y) * (j + y - 1) * (j + y - 2) * (j + y - 3) * (j + y - 4) * (j + y - 5) * (j - y + 1) * (j - y + 2) * (j - y + 3) * (j - y + 4) * (j - y + 5) * (j - y + 6))
 o#(6, 6) = JM6# / 2
 o#(6, -6) = JM6# / 2
  hr#(x + j + 1, y + j + 1) = hr#(x + j + 1, y + j + 1) + b#(6, 6) * o#(6, 6)
  hc#(x + j + 1, y + j + 1) = hc#(x + j + 1, y + j + 1) + b#(6, -6) * o#(6, -6)
END IF

5810 RETURN

281 END SUB

FUNCTION delta (x)
delta = 1 - SGN(x) * SGN(x)
END FUNCTION

DEFINT D, I-K
DEFDBL C, E, H, T
SUB diagonalize (hr#(), hc#(), d%, en(), cr#(), cc#())
DIM E(30), E2(30), tau(2, 30)
CALL htridi(d%, d%, hr#(), hc#(), en(), E(), E2(), tau())
FOR j = 1 TO d%
FOR K = 1 TO d%
cr#(j, K) = 0
IF j = K THEN cr#(j, j) = 1
NEXT: NEXT
 CALL imtql2(d%, d%, en(), E(), cr#(), Ierr)
IF Ierr <> 0 THEN PRINT "Error in diagonalise routine": STOP
 CALL htribk(d%, d%, hr#(), hc#(), tau(), d%, cr#(), cc#())
END SUB

DEFSNG C-E, H-K, T
FUNCTION divc# (ar#, ac#, br#, bc#)
 divc# = (ac# * br# - ar# * bc#) / (br# * br# + bc# * bc#)
END FUNCTION

FUNCTION divr# (ar#, ac#, br#, bc#)
 divr# = (ar# * br# + ac# * bc#) / (br# * br# + bc# * bc#)
END FUNCTION

SUB erww (hr#(), hc#(), d%, stnr%, en#(), cr#(), cc#(), tew#)
 REM ********************************************************************
 REM diese sub berechnet den erwartungswert tew# des hermiteschen
 REM operators hr#()+i.hc#() f�r den Zustand n%
 REM eingabe
 REM hr#(1..d%,1..d%)+i.hc#(1..d%.1..d%)...operatorkomponenten
 REM d%....................................dimension des zustandraums
 REM EN#(1..d%)............................energieeigenwerte in meV
 REM cr#(I,1..d%)+i.cc#(I,1..d%)...........eigenzustandskomponenten (I=1..d%)
 REM stnr%.................................nummer des zustands, fuer den der erww
 REM                                       berechnet werden soll
 REM ausgabe:
 REM tew#..................................thermischer erwartungswert
 REM ********************************************************************

 REM berechnung des erwartungswertes
 tew# = 0: dd% = 0
 FOR i = 1 TO d%
  REM berechnung des erwartungswertes von hr#()+i.hc#() im zustand I
  ewr# = 0: ewc# = 0
  FOR m = 1 TO d%: FOR n = 1 TO d%
   zr# = multr#(cr#(i, m), -cc#(i, m), hr#(m, n), hc#(m, n))
   zc# = multc#(cr#(i, m), -cc#(i, m), hr#(m, n), hc#(m, n))
   ewr# = ewr# + multr#(zr#, zc#, cr#(i, n), cc#(i, n))
   ewc# = ewc# + multc#(zr#, zc#, cr#(i, n), cc#(i, n))
  NEXT n: NEXT m
  IF ABS(ewc#) > 1E-10 THEN PRINT "fehler termerww: zustand"; i; "erwartungswert nicht reell!"
  'PRINT "state "; i; "-erwartungswert="; ewr#
  IF ABS(en#(i) - en#(stnr%)) < .01 THEN tew# = tew# + ewr#: dd% = dd% + 1
 NEXT i
 tew# = tew# / dd%

END SUB

SUB headerinput (text$(), j, n)
'**********************************************************************
' input file header of measurement file opened with #n
' the file header inputted has then j lines and is stored in text$(1-j)
'**********************************************************************

1 LINE INPUT #n, a$
   i = INSTR(a$, "{"): IF i > 0 GOTO 2 ELSE GOTO 1     'look for "{"
2 text$(1) = RIGHT$(a$, LEN(a$) - i)
  j = 1: i = INSTR(text$(j), "}"): IF i > 0 GOTO 3  'look for "}" in first line
                                        
   FOR j = 2 TO 300
   LINE INPUT #n, text$(j)
   i = INSTR(text$(j), "}"): IF i > 0 GOTO 3      'look for "}"
   NEXT j: PRINT "text in data file too long": END
3 text$(j) = LEFT$(text$(j), i - 1)



END SUB

DEFINT I-N
DEFDBL A, H, S-T, Z
SUB htribk (NM, n, ar(), ai(), tau(), m, zr(), ZI())
'     -------------------------------------------------------------------
'     This subroutine is a translation of a complex analogue of the
'     algol procedure TRED1, Num. Math. 11, 181-195 (1968) by
'     Martin, Reinsch, and Wilkinson.
'     Handbook for Auto. Comp., Vol.II - Linear Algebra, 212-226 (1971).
'
'     This subroutine forms the eigenvectors of a complex Hermitean
'     matrix by back transforming those of the corresponding real
'     symmetric tridiagonal matrix determined by HTRIDI.
'
'     On input:
'
'          NM must be set to the row dimension of the two-dimensional
'          array parameters as declared in the calling program
'          dimension statement.
'
'          N is the order of the matrix.
'
'          AR and AI contain information about the unitary trans-
'          formations used in the reduction of HTRIDI in their full
'          lower triangles except for the diagonal of AR.
'
'          TAU contains further information about the transformation.
'
'          M is the number of eigenvectors to be back transformed.
'
'          ZR contains the eigenvectors to be back transformed
'          in its first M columns.
'
'     On output:
'
'          ZR and ZI contain the real and imaginary parts,
'          respectively, of the transformed eigenvectors in
'          their first M columns.
'
'     Note that the last component of each returned vector is
'     real and that vector euclidean norms are preserved.
'
'     Qustions and comments should be directed to B.S. Garbow,
'     Applied Mathematics Division, Argonne National Laboratory.
'
'     ------------------------------------------------------------------
'
'     :::::::: Transform the eigenvectors of the real symmetric
'              tridiagonal matrix to those of the Hermitean
'              tridiagonal matrix. ::::::::::::::::::::::::::::
'
      FOR K = 1 TO n
      FOR j = 1 TO m
      ZI(j, K) = -zr(j, K) * tau(2, K)
      zr(j, K) = zr(j, K) * tau(1, K)
50    NEXT: NEXT
      IF n = 1 GOTO 200
'     :::::::::::: RECOVER AND APPLY THE HOUSEHOLDER MATRICES :::::::
      FOR i = 2 TO n
      l = i - 1
      h = ai(i, i)
      IF h = 0! GOTO 140
      FOR j = 1 TO m
      S = 0!
      SI = 0!
      FOR K = 1 TO l
      S = S + ar(i, K) * zr(j, K) - ai(i, K) * ZI(j, K)
      SI = SI + ar(i, K) * ZI(j, K) + ai(i, K) * zr(j, K)
      NEXT
      S = S / h
      SI = SI / h
      FOR K = 1 TO l
      zr(j, K) = zr(j, K) - S * ar(i, K) - SI * ai(i, K)
      ZI(j, K) = ZI(j, K) - SI * ar(i, K) + S * ai(i, K)
    NEXT
    NEXT
140 NEXT
'     :::::::::::: LAST LINE OF HTRIBK :::::::::::::::::::::::::::
200 END SUB

DEFSNG M, Z
DEFDBL D-G
SUB htridi (NM, n, ar(), ai(), d(), E(), E2(), tau())
'
'
'-----------------------------------------------------------------------
'
'     This subroutine is a translation of a complex analogue of
'     the algol procedure TRED1, Num. Math. 11, 181-195 (1968)
'     by Martin, Reinsch, and Wilkinson.
'     Handbook for Auto. Comp., Vol.II-Linear Algebra, 212-226 (1971).
'
'     This subroutine reduces a complex Hermitean matrix
'     to a real symmetri' tridiagonal matrix using
'     unitary similarity transformations.
'
'     On input:
'
'          NM must be set to the row dimension of two-dimensional
'          array parameters as declared in the calling program
'          dimension statements.
'
'          N is the order of the matrix.
'
'          AR and AI contain the real and imaginary parts,
'          respectively, of the complex Hermitean input matrix.
'          Only the lower triangle of the matrix need be supplied.
'
'     On output:
'
'          AR and AI contain information about the unitary trans-
'          formations used in the reduction in their full lower
'          triangles. Their strict upper triangles and the diagonal
'          of AR (and AI ?) are unaltered.
'
'          D contains the diagonal elements of the tridiagonal matrix.
'
'          E contains the subdiagonal elements of the tridiagonal
'          matrix in its last N-1 positions. E(1) is set to zero.
'
'          E2 contains the squares of the corresponding elements of E.
'          E2 may coincide with E if the squares are not needed.
'
'          TAU contains further information about the transformations
'
'     Arithmeti' is real......
'     Questions and comments should be directed to B.S. Garbow,
'     Applied Mathematics Division, Argonne National Laboratory.
'     ------------------------------------------------------------------
'
      tau(1, n) = 1!
      tau(2, n) = 0!
      FOR i = 1 TO n
100   d(i) = ar(i, i)
      NEXT
      FOR ii = 1 TO n
      i = n + 1 - ii
      l = i - 1
      h = 0!
      scale = 0!
      IF l < 1 GOTO 130
      FOR K = 1 TO l
120   scale = scale + ABS(ar(i, K)) + ABS(ai(i, K))
      NEXT K
      IF scale <> 0! GOTO 141
      tau(1, l) = 1!
      tau(2, l) = 0!
130   E(i) = 0!
      E2(i) = 0!
      GOTO 290
141   FOR K = 1 TO l
      ar(i, K) = ar(i, K) / scale
      ai(i, K) = ai(i, K) / scale
      h = h + ar(i, K) * ar(i, K) + ai(i, K) * ai(i, K)
150   NEXT K
      E2(i) = scale * scale * h
      g = SQR(h)
      E(i) = scale * g
      F = SQR(ar(i, l) * ar(i, l) + ai(i, l) * ai(i, l))
'     ::::::::: FORM NEXT DIAGONAL ELEMENT OF MATRIX T ::::::::::
      IF F = 0! GOTO 160
      tau(1, l) = (ai(i, l) * tau(2, i) - ar(i, l) * tau(1, i)) / F
      SI = (ar(i, l) * tau(2, i) + ai(i, l) * tau(1, i)) / F
      h = h + F * g
      g = 1! + g / F
      ar(i, l) = g * ar(i, l)
      ai(i, l) = g * ai(i, l)
      IF l = 1 GOTO 270
      GOTO 170
160   tau(1, l) = -tau(1, i)
      SI = tau(2, i)
      ar(i, l) = g
170   F = 0!
      FOR j = 1 TO l
      g = 0!
      GI = 0!
'     :::::::::::: FORM ELEMENT OF A*U ::::::::::::::::::::
      FOR K = 1 TO j
      g = g + ar(j, K) * ar(i, K) + ai(j, K) * ai(i, K)
      GI = GI - ar(j, K) * ai(i, K) + ai(j, K) * ar(i, K)
180 NEXT K
      JP1 = j + 1
      IF l < JP1 GOTO 220
      FOR K = JP1 TO l
      g = g + ar(K, j) * ar(i, K) - ai(K, j) * ai(i, K)
      GI = GI - ar(K, j) * ai(i, K) - ai(K, j) * ar(i, K)
     NEXT K
'     ::::::::::::: FORM ELEMENT OF P ::::::::::::::::::::::
220   E(j) = g / h
      tau(2, j) = GI / h
      F = F + E(j) * ar(i, j) - tau(2, j) * ai(i, j)
240  NEXT j
      HH = F / (h + h)
'     :::::::::::::: FORM REDUCED A ::::::::::
      FOR j = 1 TO l
      F = ar(i, j)
      g = E(j) - HH * F
      E(j) = g
      fi = -ai(i, j)
      GI = tau(2, j) - HH * fi
      tau(2, j) = -GI
      FOR K = 1 TO j
      ar(j, K) = ar(j, K) - F * E(K) - g * ar(i, K) + fi * tau(2, K) + GI * ai(i, K)
      ai(j, K) = ai(j, K) - F * tau(2, K) - g * ai(i, K) - fi * E(K) - GI * ar(i, K)
260  NEXT K: NEXT j
270   FOR K = 1 TO l
      ar(i, K) = scale * ar(i, K)
      ai(i, K) = scale * ai(i, K)
280 NEXT K
      tau(2, l) = -SI
290   HH = d(i)
      d(i) = ar(i, i)
      ar(i, i) = HH
      ai(i, i) = scale * scale * h
300   NEXT ii
'     ::::::::::::: LAST LINE OF HTRIDI ::::::::::::::::::::::::::::::

END SUB

DEFSNG A, H, T
DEFDBL C, M, P, R, Z
SUB imtql2 (NM, n, d(), E(), z(), Ierr)
'
'     --------------------------------------------------------------
'
'     This subroutine is a translation of the algol procedure IMTQL2,
'     Num. Math. 12, 377-383 (1968) by Martin and Wilkinson, as
'     modified in Num. Math. 15, 450 (1970) by Dubrulle, Handbook
'     for Auto. Comp. Vol.II - Linear Algebra, 241-248 (1971).
'
'     This subroutine finds the eigenvalues and the eigenvectors of
'     a symmetri' tridiagonal matrix by the "implicit QL method."
'     The eigenvectors of a full symmetri' matrix can also be found
'     if TRED2 has been used to reduced the full matrix to
'     tridiagonal form.
'
'     On input:
'
'          NM must be set to the row dimension of two-dimensional
'          array parameters as declared in the calling program
'          dimension statement.
'
'          N is the order of the matrix.
'
'          D contains the diagonal elements of the input matrix.
'
'          E contains the subdiagonal elements of the input matrix
'          in its last N-1 positions. E(1) is set to arbitrary.
'
'          Z contains the transformation matrix produced in the
'          reduction by TRED2, if performed. If the eigenvectors
'          of the tridiagonal matrix are desired, Z must contain
'          the identity matrix.                   **************
'          ********************
'     On output:
'
'          D contains the eigenvalues in ascending order. If an
'          error exit is made, the eigenvalues are correct but
'          unordered for indices 1,2,...,IERR-1.
'
'          E has been destroyed.
'
'          Z contains orthonormal eigenvectors of the symmetric
'          tridiagonal (or full) matrix. If an error exit is made
'          Z contains the eigenvectors associated with the stored
' eigenvalues.
'
'          IERR is set to
'               0    for normal return
'               J    if the J'th eigenvalue has not been
'                         determined after 30 iterations.
'
'     Questions and comments should be directed to B.S. Gabow,
'     Applied Mathematics Division, Argonne National Laboratory.
'
'     ------------------------------------------------------------------
'
'     :::: MACHEP is (or should have been) a machine dependent
'          parameter specifying the relative precision of floating
'          point aritmetic.(MACHEP=4*8**(-13) for single precision
'          arithmeticon B6700).  ::::::::::::::::::::::::::::::::::
'
       MACHEP = 1E-11
      Ierr = 0
      IF n = 1 GOTO 1001
      FOR i = 2 TO n
      E(i - 1) = E(i)
      NEXT
      E(n) = 0!
      FOR l = 1 TO n
      j = 0
'     ::::::: LOOK FOR SMALL SUB-DIAGONAL ELEMENT ::::::::
105   FOR m = l TO n
      IF m = n GOTO 121
      IF ABS(E(m)) <= MACHEP * (ABS(d(m)) + ABS(d(m + 1))) GOTO 121
110  NEXT
121   p = d(l)
      IF m = l GOTO 241
      IF j = 30 GOTO 1000
      j = j + 1
': : : : : : : : : : : : : : : : : FORM SHIFT: : : : : : : : : : : : : : : : : : :
      g = (d(l + 1) - p) / (2! * E(l))
      R = SQR(g * g + 1!)
      IF g = 0 THEN g = 1E-30
      g = d(m) - p + E(l) / (g + SGN(g) * ABS(R))
      S = 1!
      C = 1!
      p = 0!
      MML = m - l
      FOR ii = 1 TO MML
      i = m - ii
      F = S * E(i)
      b = C * E(i)
      IF ABS(F) < ABS(g) GOTO 151
      C = g / F
      R = SQR(C * C + 1!)
      E(i + 1) = F * R
      S = 1! / R
      C = C * S
      GOTO 161
151   S = F / g
      R = SQR(S * S + 1!)
      E(i + 1) = g * R
      C = 1! / R
      S = S * C
161   g = d(i + 1) - p
      R = (d(i) - g) * S + 2! * C * b
      p = S * R
      d(i + 1) = g + p
      g = C * R - b
'     ::::::::::::::::::  FORM VECTOR :::::::::::::::
      FOR K = 1 TO n
      F = z(i + 1, K)
      z(i + 1, K) = S * z(i, K) + C * F
      z(i, K) = C * z(i, K) - S * F
181   NEXT
201  NEXT
      d(l) = d(l) - p
      E(l) = g
      E(m) = 0!
      GOTO 105
241 NEXT
'     :::::::ORDER EIGENVALUES AND EIGENVECTORS :::::::::::
      FOR ii = 2 TO n
      i = ii - 1
      K = i
      p = d(i)
      FOR j = ii TO n
      IF d(j) >= p GOTO 261
      K = j
      p = d(j)
261  NEXT
      IF K = i GOTO 301
      d(K) = d(i)
      d(i) = p
      FOR j = 1 TO n
      p = z(i, j)
      z(i, j) = z(K, j)
      z(K, j) = p
     NEXT
301  NEXT
      GOTO 1001
'     :::::::::::: SET ERROR--NO CONVERGENCE TO AN
'                   EIGRNVALUE AFTER 30 ITERATIONS :::::::::::
1000  Ierr = l
'     ::::::::::::::: LAST LINE OF ITMQL2 ::::::::::::::::::::::::::

1001 END SUB

DEFSNG C-G, I-N, P, R-S, Z
SUB inputline (n, d1#(), col1%, d2$(), col2%)
'input data point line on #n as string and split into numbers
' determine col1% and save data columns in d1#(1...col1%)
'comments in {} are stored in d2$
'if a comment is started somewhere in this line by "{" and not finished
'then col1% is set -1 and the filepointer is set to the beginning of the
'line (with seek)

aa = SEEK(n)
LINE INPUT #n, ala$
WHILE INSTR(ala$, CHR$(9)) > 0  'abandon tabs
 i% = INSTR(ala$, CHR$(9))
 ala$ = LEFT$(ala$, i% - 1) + " " + MID$(ala$, i% + 1)
WEND
'treat comments in input line
klauf% = INSTR(ala$, "{")
klzu% = INSTR(ala$, "}")
col2% = 0
WHILE klauf% < klzu% AND klauf% > 0   'take out closed bracketed expressions
 col2% = col2% + 1
 d2$(col2%) = MID$(ala$, klauf% + 1, klzu% - klauf% - 1)
 ala$ = LEFT$(ala$, klauf% - 1) + " " + MID$(ala$, klzu% + 1)
 klauf% = INSTR(ala$, "{")
 klzu% = INSTR(ala$, "}")
WEND


IF klauf% > 0 THEN
 col1% = -1: SEEK n, aa 'a comment bracket is not closed ... no data read
ELSE
 col1% = 0
 WHILE LEN(ala$) > 0
    col1% = col1% + 1
    ala$ = LTRIM$(ala$) + " "
    d1#(col1%) = VAL(LEFT$(ala$, INSTR(ala$, " ")))
    ala$ = LTRIM$(RIGHT$(ala$, LEN(ala$) - INSTR(ala$, " ")))
 WEND
END IF

END SUB

FUNCTION multc# (ar#, ac#, br#, bc#)
 multc# = ac# * br# + ar# * bc#
END FUNCTION

FUNCTION multr# (ar#, ac#, br#, bc#)
 multr# = ar# * br# - ac# * bc#
END FUNCTION

DEFINT I-J
SUB plot (a(), cnst())
STATIC nr, stp
SHARED programpath$, T, hx, hy, hz, selfcon%, statenumber%
REM dieses programm berechnet aus alm die ladungsdichteverteilung
REM und zeichnet diese auf
anzahl% = 0: stp = stp * 180 / 3.1415
PRINT "stepwidth in deg<"; stp; ">"; :
INPUT ala$: IF ala$ <> "" THEN stp = VAL(ala$)
IF stp = 0 THEN stp = 20
stp = stp / 180 * 3.1415

SCREEN 12
imax = 3: DIM rp(imax, 22, 40)
DIM xn(3, 4000), yn(3, 4000), mu(100), mo(100), m(3), x1z(4), il(4)

REM flaeche ro=konst. bestimmen
INPUT "plot of constant charge density: const=<0.05>"; konst
IF konst = 0 THEN konst = .05
'konst = .05
rmax = 0: rstp = .1
max = .01 * konst  'end of intervalschachtelung to find r(ro=konst.)

FOR tt% = 0 TO 3.1415 / stp + 1
FOR ff% = 0 TO 2 * 3.1415 / stp + 1
    FOR i = 0 TO imax: rp(i, tt%, ff%) = 0: NEXT i
    i = 0: teta = tt% * stp: fi = ff% * stp
    FOR rin = .1 TO 2.2 STEP .2: R = rin
  
     CALL rocalc(ro, teta, fi, R, a(), cnst())
     deltaa = ABS(ro - konst): rstpp = rstp
     FOR ii = 1 TO 100
     R = R + rstpp
     CALL rocalc(ro, teta, fi, R, a(), cnst())
     delta1 = ABS(ro - konst): 'PRINT r, ro
     IF delta1 < max GOTO 22
     REM intervallschachtelung
     IF delta1 < deltaa THEN deltaa = delta1: GOTO 21
     IF delta1 >= deltaa THEN R = R - rstpp: rstpp = -.5 * rstpp: GOTO 21
21 NEXT ii: GOTO 25
22 FOR iii = 1 TO i
    IF ABS(rp(iii, tt%, ff%) - R) < .1 GOTO 25
   NEXT iii
    i = i + 1: rp(i, tt%, ff%) = R: 'PRINT R
'    IF R > 2 THEN PRINT "large r at teta/fi/ro/R"; teta; fi; ro; R: INPUT ala
    IF R > rmax THEN rmax = R
    anzahl% = anzahl% + 1
25 NEXT rin:
'IF ff% > 0 THEN rp(1, tt%, ff%) = rp(1, tt%, ff% - 1) ELSE rp(1, tt%, ff%) = rp(1, tt% - 1, 0)
'i = i + 1
 IF i = 0 THEN rp(1, tt%, ff%) = .05: rp(2, tt%, ff%) = .06
 IF i = 1 THEN rp(2, tt%, ff%) = rp(1, tt%, ff%) + .0001

 NEXT
NEXT


REM******************************************************************************
231 REM verdeckte linien entfernend ausdrucken
PRINT "plot view angle<15>"
PRINT "1...view along x axis"
PRINT "2...view along y axis"
INPUT "3..view along z axis"; alpha1
nr = nr + 1
IF alpha1 = 0 THEN alpha1 = 15
alpha = alpha1 / 180 * 3.1415
OPEN "o", 1, programpath$ + "chrgpl" + CHR$(nr + 96) + ".ps"
OPEN "o", 2, programpath$ + "chrgpl" + CHR$(nr + 96) + ".jvx"
PRINT #9, "graph saved in "; programpath$ + "chrgpl" + CHR$(nr + 96) + ".ps"
PRINT #9, "3d data saved in "; programpath$ + "chrgpl" + CHR$(nr + 96) + ".jvx"

PRINT #2, "<?xml version=" + CHR$(34) + "1.0" + CHR$(34) + " encoding=" + CHR$(34) + "ISO-8859-1" + CHR$(34) + " standalone=" + CHR$(34) + "no" + CHR$(34) + "?>"
PRINT #2, "<!DOCTYPE jvx-model SYSTEM " + CHR$(34) + "http://www.javaview.de/rsrc/jvx.dtd" + CHR$(34) + ">"
PRINT #2, "<jvx-model>	<meta generator=" + CHR$(34) + "JavaView v.2.00.008" + CHR$(34) + "/>"
PRINT #2, "<meta date=" + CHR$(34) + "Wed Mar 07 22:30:58 GMT+01:00 2001" + CHR$(34) + "/>"
PRINT #2, "<version type=" + CHR$(34) + "dump" + CHR$(34) + ">0.02</version>"

CLS : PRINT "press esc to stop plotting"
fktr = 1: scalex = 100: scaley = scalex * fktr
xnull = 300: ynull = 240
schluck = .02
REM achsenkreuz
PRINT #1, "/Helvetica findfont"
PRINT #1, "12 scalefont setfont"

PRINT #1, "10 30 moveto"
IF statenumber% = 0 THEN
PRINT #1, "(thermal expectation value of 4f charge density) show"
ELSE
PRINT #1, "(expectation value of state number "; statenumber%; ") show"
END IF
PRINT #1, "10 20 moveto"
PRINT #1, USING "(T=####.###K h||x=###.###T h||y=###.###T h||z=###.###T)"; T; hx; hy; hz;
PRINT #2, USING "<title>T=####.###K h||x=###.###T h||y=###.###T h||z=###.###T</title>"; T; hx; hy; hz;
PRINT #2, "<geometries> 		<geometry name=" + CHR$(34);
PRINT #2, USING "T=####.###K h||x=###.###T h||y=###.###T h||z=###.###T"; T; hx; hy; hz;
PRINT #2, CHR$(34) + ">"
PRINT #1, " show "
IF selfcon% = 1 THEN
 PRINT #1, "10 10 moveto"
 PRINT #1, "(selfconsistent calculatation of charge density using q-interactions) show"
END IF

PRINT #2, "<pointSet color=" + CHR$(34) + "hide" + CHR$(34) + " point=" + CHR$(34) + "show" + CHR$(34) + " dim=" + CHR$(34) + "1" + CHR$(34) + ">"
ntt% = INT(3.1415 / stp)
nff% = INT(2 * 3.1415 / stp)
pointnr% = ntt% * (nff% + 1)
PRINT #2, "<points num=" + CHR$(34) + STR$(pointnr% + 1) + CHR$(34) + ">"
 tt% = 0: ff% = 0: R = 0
  FOR i = 1 TO imax
   IF rp(i, tt%, ff%) > R THEN R = rp(i, tt%, ff%)
  NEXT i
        x = R * SIN(stp * tt%) * COS(ff% * stp)
        y = R * SIN(stp * tt%) * SIN(ff% * stp)
        z = R * COS(stp * tt%)
    PRINT #2, USING "<p>##.####^^^^ ##.####^^^^ ##.####^^^^</p>"; x; y; z

  FOR tt% = 1 TO ntt%
  FOR ff% = 0 TO nff%
  R = 0:
  FOR i = 1 TO imax
   IF rp(i, tt%, ff%) > R THEN R = rp(i, tt%, ff%)
  NEXT i
        x = R * SIN(stp * tt%) * COS(ff% * stp)
        y = R * SIN(stp * tt%) * SIN(ff% * stp)
        z = R * COS(stp * tt%)
    PRINT #2, USING "<p>##.####^^^^ ##.####^^^^ ##.####^^^^</p>"; x; y; z
NEXT: NEXT

PRINT #2, "<thickness>0.0</thickness><color type=" + CHR$(34) + "rgb" + CHR$(34) + ">255 0 0</color><colorTag type=" + CHR$(34) + "rgb" + CHR$(34) + ">255 0 255</colorTag>"
PRINT #2, "</points>			</pointSet>"
PRINT #2, "<faceSet face=" + CHR$(34) + "show" + CHR$(34) + " edge=" + CHR$(34) + "show" + CHR$(34) + ">"
PRINT #2, "<faces num=" + CHR$(34) + STR$(pointnr%) + CHR$(34) + ">"

  FOR tt% = 1 TO ntt%
  ffnr% = nff% + 1
  FOR ff% = 0 TO nff%
   p1% = ff% + 1 + (tt% - 2) * ffnr%
   p2% = ff% + 2 + (tt% - 2) * ffnr%
   p3% = ff% + 2 + (tt% - 1) * ffnr%
   p4% = ff% + 1 + (tt% - 1) * ffnr%
   IF ff% = nff% THEN p3% = p3% - ffnr%: p2% = p2% - ffnr%
   IF tt% = 1 THEN p1% = 0: p2% = 0
   PRINT #2, "<f>"; p1%; " "; p2%; " "; p3%; " "; p4%; "</f>"
  NEXT: NEXT

PRINT #2, "<color type=" + CHR$(34) + "rgb" + CHR$(34) + ">100 230 255</color>"
PRINT #2, "<colorTag type=" + CHR$(34) + "rgb" + CHR$(34) + ">255 0 255</colorTag>"
PRINT #2, "</faces></faceSet></geometry></geometries></jvx-model>"
CLOSE 2

IF alpha1 > 3 THEN
LINE (xnull + rmax * 1.5 * scalex, ynull)-(xnull + rmax * 1.9 * scalex, ynull)
LINE (xnull, ynull - rmax * 1.5 * scaley)-(xnull, ynull - rmax * 1.9 * scaley)
LINE (xnull - COS(alpha) * rmax * 1.5 * scalex, ynull + SIN(alpha) * rmax * 1.5 * scaley)-(xnull - COS(alpha) * rmax * 1.9 * scalex, ynull + SIN(alpha) * rmax * 1.9 * scaley)
  PRINT #1, xnull + rmax * 1.5 * scalex, ynull; " moveto"
  PRINT #1, xnull + rmax * 1.9 * scalex, ynull; " lineto"
  PRINT #1, "(y) show"
  PRINT #1, xnull, ynull + rmax * 1.5 * scaley; " moveto"
  PRINT #1, xnull, ynull + rmax * 1.9 * scaley; " lineto"
  PRINT #1, "(z) show"
  PRINT #1, xnull - COS(alpha) * rmax * 1.5 * scalex, ynull - SIN(alpha) * rmax * 1.5 * scaley; " moveto"
  PRINT #1, xnull - COS(alpha) * rmax * 1.9 * scalex, ynull - SIN(alpha) * rmax * 1.9 * scaley; " lineto"
  PRINT #1, "(         x) show"
END IF
IF alpha1 < 4 THEN
LINE (xnull + rmax * 1.5 * scalex, ynull)-(xnull + rmax * 1.9 * scalex, ynull)
LINE (xnull, ynull - rmax * 1.5 * scaley)-(xnull, ynull - rmax * 1.9 * scaley)
  PRINT #1, xnull + rmax * 1.5 * scalex, ynull; " moveto"
  PRINT #1, xnull + rmax * 1.9 * scalex, ynull; " lineto"
  IF alpha1 = 1 THEN PRINT #1, "(y) show"
  IF alpha1 = 2 THEN PRINT #1, "(x) show"
  IF alpha1 = 3 THEN PRINT #1, "(x) show"
  PRINT #1, xnull, ynull + rmax * 1.5 * scaley; " moveto"
  PRINT #1, xnull, ynull + rmax * 1.9 * scaley; " lineto"
  IF alpha1 = 1 THEN PRINT #1, "(z) show"
  IF alpha1 = 2 THEN PRINT #1, "(z) show"
  IF alpha1 = 3 THEN PRINT #1, "(y) show"
END IF
drk = 1
REM beobachterrichtung
IF alpha1 > 3 THEN
fib = ATN(COS(alpha))
tetab = ATN(1 / COS(fib) / SIN(alpha))
xbeo = SIN(tetab) * COS(fib)
ybeo = SIN(tetab) * SIN(fib)
zbeo = COS(tetab)
END IF
IF alpha1 = 1 THEN xbeo = 1: ybeo = 0: zbeo = 0
IF alpha1 = 2 THEN xbeo = 0: ybeo = 1: zbeo = 0
IF alpha1 = 3 THEN xbeo = 0: ybeo = 0: zbeo = 1
FOR zahler% = 1 TO anzahl%

REM suche des punktes mit groesstem beta
 max = -20
  FOR tt% = 1 TO 3.1415 / stp - 1
  FOR ff% = 0 TO 2 * 3.1415 / stp - 1
  FOR i = 1 TO imax
   IF rp(i, tt%, ff%) = 0 GOTO 6
        IF SGN(rp(i, tt%, ff%)) = -1 GOTO 6
        x = SIN(stp * tt%) * COS(ff% * stp)
        y = SIN(stp * tt%) * SIN(ff% * stp)
        z = COS(stp * tt%)
        betas = x * xbeo + y * ybeo + z * zbeo
        IF betas > max THEN max = betas: ip = i: ttp = tt%: ffp = ff%
6 NEXT: NEXT: NEXT
 REM gefunden
 'IF ttp = 0 OR ttp = INT(3.1415 / stp) GOTO 14
 R = ABS(rp(ip, ttp, ffp)): teta = ttp * stp: fi = ffp * stp
 x = R * SIN(teta) * COS(fi): y = R * SIN(teta) * SIN(fi): z = R * COS(teta)
IF alpha1 > 3 THEN xs = y - x * COS(alpha): ys = z - x * SIN(alpha)
IF alpha1 = 1 THEN xs = y: ys = z
IF alpha1 = 2 THEN xs = x: ys = z
IF alpha1 = 3 THEN xs = x: ys = y
 ttl% = ttp - 1: ffl% = ffp: GOSUB 11: x1z(1) = beta: il(1) = 1
 ttl% = ttp: ffl% = ffp + 1: GOSUB 11: x1z(2) = beta: il(2) = 2
 ttl% = ttp + 1: ffl% = ffp: GOSUB 11: x1z(3) = beta: il(3) = 3
 ttl% = ttp: ffl% = ffp - 1: GOSUB 11: x1z(4) = beta: il(4) = 4
FOR iii = 1 TO 3
IF x1z(4) < x1z(iii) THEN
xsave = x1z(4): x1z(4) = x1z(iii): x1z(iii) = xsave
ilsav = il(4): il(4) = il(iii): il(iii) = ilsave
END IF
NEXT
il(3) = il(4) + 1: IF il(3) = 5 THEN il(3) = 1
il(2) = il(4) - 1: IF il(2) = 0 THEN il(2) = 4
il(1) = 10 - il(4) - il(3) - il(2)

FOR ii12 = 1 TO 4
ON il(ii12) GOTO 221, 222, 223, 224
221 ttl% = ttp - 1: ffl% = ffp: GOSUB 11: GOSUB 15: GOTO 225
222 ttl% = ttp: ffl% = ffp + 1: GOSUB 11: GOSUB 15: GOTO 225
223 ttl% = ttp + 1: ffl% = ffp: GOSUB 11: GOSUB 15: GOTO 225
224 ttl% = ttp: ffl% = ffp - 1: GOSUB 11: GOSUB 15: GOTO 225
225 IF ii12 = 1 THEN
xn(1, drk) = xs: yn(1, drk) = ys
xn(2, drk) = xs1: yn(2, drk) = ys1
xn(2, drk + 1) = xs1: yn(2, drk + 1) = ys1
END IF
IF ii12 = 2 THEN
xn(3, drk) = xs1: yn(3, drk) = ys1
drk = drk + 1
xn(1, drk) = xs: yn(1, drk) = ys
xn(2, drk + 1) = xs1: yn(2, drk + 1) = ys1
END IF
IF ii12 = 3 THEN
xn(3, drk) = xs1: yn(3, drk) = ys1
drk = drk + 1
xn(1, drk) = xs: yn(1, drk) = ys
xn(2, drk + 1) = xs1: yn(2, drk + 1) = ys1
END IF
IF ii12 = 4 THEN
xn(3, drk) = xs1: yn(3, drk) = ys1
drk = drk + 1
xn(1, drk) = xs: yn(1, drk) = ys
xn(3, drk) = xs1: yn(3, drk) = ys1
drk = drk + 1
END IF
NEXT
14 rp(ip, ttp, ffp) = -ABS(rp(ip, ttp, ffp))
a$ = INKEY$: IF a$ <> "" THEN IF ASC(a$) = 27 THEN GOTO 23

NEXT zahler%
23  PRINT #1, "stroke ": PRINT #1, " showpage"
 CLOSE 1
INPUT "view from another angle (y/n)"; a$
IF a$ = "y" THEN
  FOR tt% = 1 TO 3.1415 / stp - 1
  FOR ff% = 0 TO 2 * 3.1415 / stp - 1
  FOR i = 1 TO imax
  rp(i, tt%, ff%) = ABS(rp(i, tt%, ff%))
NEXT: NEXT: NEXT
GOTO 231
END IF
GOTO 131

11 j = ip
IF ttl% = -1 THEN STOP: RETURN
IF ffl% = -1 THEN ffl% = INT(2 * 3.14152 / stp - 1)
7 IF j = 1 GOTO 8
IF rp(j, ttl%, ffl%) = 0 THEN j = j - 1: GOTO 7
8 r1 = ABS(rp(j, ttl%, ffl%)): teta = ttl% * stp: fi = ffl% * stp
x1 = r1 * SIN(teta) * COS(fi)
y1 = r1 * SIN(teta) * SIN(fi)
z1 = r1 * COS(teta)
beta = (xbeo * x1 + ybeo * y1 + zbeo * z1) / r1
RETURN
15 REM linedraw

IF alpha1 > 3 THEN xs1 = y1 - x1 * COS(alpha): ys1 = z1 - x1 * SIN(alpha)
IF alpha1 = 1 THEN xs1 = y1: ys1 = z1
IF alpha1 = 2 THEN xs1 = x1: ys1 = z1
IF alpha1 = 3 THEN xs1 = x1: ys1 = y1

REM check, ob Linie verdeckt geh"ort und eventuell K"urzen der linie
del = 0
FOR check = 1 TO drk - 1
 xa = xn(1, check): xb = xn(2, check): xc = xn(3, check)
 ya = yn(1, check): yb = yn(2, check): yc = yn(3, check)
 GOSUB 12
IF del = 1 AND mu(1) = 0 AND mo(1) = 1 THEN check = drk
NEXT check
REM umordnen der auszuloeschenden intervalle
FOR iii = del TO 1 STEP -1: FOR i2 = 1 TO iii
IF mu(iii) < mu(i2) THEN
 mm = mu(iii): mu(iii) = mu(i2): mu(i2) = mm
 mm = mo(iii): mo(iii) = mo(i2): mo(i2) = mm
END IF
NEXT: NEXT
REM druck der (unterbrochenen) linie
xx1 = xs: yy1 = ys: mu(del + 1) = 1
FOR iii = 1 TO del + 1
  xx = xs + mu(iii) * (xs1 - xs): yy = ys + mu(iii) * (ys1 - ys)
  dx = xx - xx1: dy = yy - yy1
  IF ABS(dx * dx - dy * dy) > schluck * schluck THEN
LINE (xnull + xx1 * scalex, ynull - yy1 * scaley)-(xnull + xx * scalex, ynull - yy * scaley)
  PRINT #1, xnull + xx1 * scalex, ynull + yy1 * scaley; " moveto"
  PRINT #1, xnull + xx * scalex, ynull + yy * scaley; " lineto"
  END IF
  xx1 = xs + mo(iii) * (xs1 - xs): yy1 = ys + mo(iii) * (ys1 - ys)
NEXT
  xs1 = xs + .999 * (xs1 - xs): ys1 = ys + .999 * (ys1 - ys)
RETURN


12 REM check ob linie verdeckt durch dreieck a-b-c
REM seite ab
px1 = xa: py1 = ya: px2 = xb: py2 = yb: GOSUB 13: lab = l: mab = m
REM seite bc
px1 = xb: py1 = yb: px2 = xc: py2 = yc: GOSUB 13: lbc = l: mbc = m
REM seite ca
px1 = xc: py1 = yc: px2 = xa: py2 = ya: GOSUB 13: lca = l: mca = m
IF lab > 0 AND lab < 1 AND mab > 0 AND mab < 1 THEN m(1) = mab ELSE m(1) = -1
IF lbc > 0 AND lbc < 1 AND mbc > 0 AND mbc < 1 THEN m(2) = mbc ELSE m(2) = -1
IF lca > 0 AND lca < 1 AND mca > 0 AND mca < 1 THEN m(3) = mca ELSE m(3) = -1
IF m(1) + m(2) + m(3) = -3 THEN
    xss = (xs1 + xs) / 2: yss = (ys1 + ys) / 2
    IF SGN((xss - xb) * (yb - ya) + (yss - yb) * (xa - xb)) = SGN((xc - xb) * (yb - ya) + (yc - yb) * (xa - xb)) THEN
    IF SGN((xss - xc) * (yc - yb) + (yss - yc) * (xb - xc)) = SGN((xa - xc) * (yc - yb) + (ya - yc) * (xb - xc)) THEN
    IF SGN((xss - xa) * (ya - yc) + (yss - ya) * (xc - xa)) = SGN((xb - xa) * (ya - yc) + (yb - ya) * (xc - xa)) THEN
 del = 1: mu(1) = 0: mo(1) = 1
    END IF
    END IF
    END IF
RETURN
 END IF


mmax = 0: mmin = 1
FOR iii = 1 TO 3
IF m(iii) = -1 GOTO 452
IF m(iii) > mmax THEN mmax = m(iii): isave = iii
IF m(iii) < mmin THEN mmin = m(iii): isave = iii
452 NEXT iii

IF mmax = mmin THEN
  IF isave = 1 THEN
    IF SGN((xs1 - xb) * (yb - ya) + (ys1 - yb) * (xa - xb)) = -SGN((xc - xb) * (yb - ya) + (yc - yb) * (xa - xb)) THEN
     mmin = 0
    ELSE
     mmax = 1
    END IF
  END IF
  IF isave = 2 THEN
    IF SGN((xs1 - xc) * (yc - yb) + (ys1 - yc) * (xb - xc)) = -SGN((xa - xc) * (yc - yb) + (ya - yc) * (xb - xc)) THEN
     mmin = 0
    ELSE
     mmax = 1
    END IF
  END IF
  IF isave = 3 THEN
    IF SGN((xs1 - xa) * (ya - yc) + (ys1 - ya) * (xc - xa)) = -SGN((xb - xa) * (ya - yc) + (yb - ya) * (xc - xa)) THEN
     mmin = 0
    ELSE
     mmax = 1
    END IF
   END IF
END IF
del = del + 1: mu(del) = mmin: mo(del) = mmax

REM check ob neuer bereich nicht mit anderen ueberlappt
312 FOR iii = 1 TO del
FOR ii = 1 TO del
IF ii = iii GOTO 313
IF mo(iii) < mu(ii) OR mu(iii) > mo(ii) GOTO 313
IF mo(iii) < mo(ii) THEN mo(iii) = mo(ii)
IF mu(iii) > mu(ii) THEN mu(iii) = mu(ii)
 IF iii = del THEN
 msave = mo(iii): mo(iii) = mo(ii): mo(ii) = msave
 msave = mu(iii): mu(iii) = mu(ii): mu(ii) = msave
 END IF
 msave = mo(ii): mo(ii) = mo(del): mo(del) = msave
 msave = mu(ii): mu(ii) = mu(del): mu(del) = msave
del = del - 1
GOTO 312
313 NEXT: NEXT
RETURN

13 REM schnitt zweier geraden
cx = xs1 - xs: cy = ys1 - ys
bx = px2 - px1: by = py2 - py1
det = bx * cy - cx * by
IF ABS(det) < 1E-10 THEN l = 1E+34: m = 1E+34: RETURN
ax = px1 - xs: ay = py1 - ys
m = (-ax * by + ay * bx) / det
l = (-ax * cy + ay * cx) / det
RETURN
131 END SUB

DEFSNG I-J
SUB prtewuev (en#(), cr#(), cc#(), j)
REM**********************************************************************
REM ausgabe der eigenwerte und eigenvektoren
REM eingabe:
REM EN#(1..2J+1).....................eigenwerte
REM cr#(I,1..2J+1)+i.cc#(I,1..2J+1)..eigenvektoren
REM J................................drehimpulsquantenzahl
REM**********************************************************************
DIM un(4), unit$(4)
un(3) = 11.6045036#: un(4) = 1: un(2) = .24179696#: un(1) = 806.5479#
unit$(3) = " (K)": unit$(4) = " (meV)": unit$(2) = " (THz)": unit$(1) = " (/m)"
PRINT "Eigenwerte und Eigenvektoren:"
PRINT #9, "Eigenwerte und Eigenvektoren:"
 FOR n = 1 TO 4
 PRINT : PRINT "Eclc";
 PRINT #9, : PRINT #9, "Eclc";
FOR i = 1 TO 2 * j + 1:
PRINT USING "###.###"; en#(i) * un(n);
PRINT #9, USING "###.###"; en#(i) * un(n); : NEXT i
PRINT unit$(n): PRINT "Eclc";
PRINT #9, unit$(n): PRINT #9, "Eclc";
FOR i = 1 TO 2 * j + 1: PRINT USING "###.###"; (en#(i) - en#(1)) * un(n); : NEXT i
FOR i = 1 TO 2 * j + 1: PRINT #9, USING "###.###"; (en#(i) - en#(1)) * un(n); : NEXT i
PRINT unit$(n)
PRINT #9, unit$(n)
NEXT n
INPUT ala
CALL viewmatrix(cr#(), cc#(), 2 * j + 1, 2 * j + 1, "eigenstates")
INPUT ala
REM************************************************************************
REM  transitionenergies groundstate> exc.state and probabilities
REM anzahl,energien fuer die verrschiedenen plaetze
REM************************************************************************
REM feststellen der entartung des  grundzustandes
ent = 1: FOR m = 2 TO 2 * j + 1: IF en#(m) - en#(1) < .0001 THEN ent = m
NEXT
sa = 0
PRINT "Trans.Prob."
PRINT #9, "Trans.Prob."
PRINT "|a> -> |b>    |<a|Jx|b>|^2 |<a|Jy|b>|^2 |<a|Jz|b>|^2"
PRINT #9, "|a> -> |b>    |<a|Jx|b>|^2 |<a|Jy|b>|^2 |<a|Jz|b>|^2"
FOR m = ent + 1 TO 2 * j + 1
px = 0: py = 0: pz = 0: FOR K = 1 TO ent
 REM transitiponprobability px,py,pz en(k)>en(m)
 jzr# = 0: jzc# = 0: jxr# = 0: jxc# = 0: jyr# = 0: jyc# = 0
 FOR x = -j TO j: FOR y = -j TO j
  JP1# = 0: IF x = y + 1 THEN JP1# = SQR((j - y) * (j + y + 1))
  JM1# = 0: IF x = y - 1 THEN JM1# = SQR((j + y) * (j - y + 1))
  jzr# = jzr# + multr(cr#(K, x + j + 1), -cc#(K, x + j + 1), cr#(m, y + j + 1), cc#(m, y + j + 1)) * x * delta(x - y)
  jzc# = jzc# + multc(cr#(K, x + j + 1), -cc#(K, x + j + 1), cr#(m, y + j + 1), cc#(m, y + j + 1)) * x * delta(x - y)
  jxr# = jxr# + multr(cr#(K, x + j + 1), -cc#(K, x + j + 1), cr#(m, y + j + 1), cc#(m, y + j + 1)) * (JP1# + JM1#) / 2
  jxc# = jxc# + multc(cr#(K, x + j + 1), -cc#(K, x + j + 1), cr#(m, y + j + 1), cc#(m, y + j + 1)) * (JP1# + JM1#) / 2
  jyr# = jyr# + multc(cr#(K, x + j + 1), -cc#(K, x + j + 1), cr#(m, y + j + 1), cc#(m, y + j + 1)) * (-JP1# + JM1#) / 2: REM imaginaer
  jyc# = jyc# + multr(cr#(K, x + j + 1), -cc#(K, x + j + 1), cr#(m, y + j + 1), cc#(m, y + j + 1)) * (-JP1# + JM1#) / 2: REM imaginaer
 NEXT: NEXT
 px = px + jxr# * jxr# + jxc# * jxc#
 py = py + jyr# * jyr# + jyc# * jyc#
 pz = pz + jzr# * jzr# + jzc# * jzc#
NEXT K
PRINT "|1> -> |"; m; ">",
PRINT #9, "|1> -> |"; m; ">",
PRINT USING "######.#####"; px,
PRINT #9, USING "######.#####"; px,
PRINT USING "######.#####"; py,
PRINT #9, USING "######.#####"; py,
PRINT USING "######.#####"; pz
PRINT #9, USING "######.#####"; pz
 NEXT m


END SUB

SUB rocalc (ro, teta, fi, R, a(), cnst())
IF R > 3 OR R < 0 THEN ro = 1E+10: GOTO 421
ct = COS(teta)                      'z
ct2 = ct * ct
st = SIN(teta)
st2 = st * st
sfi = SIN(fi)
cfi = COS(fi)
'k = 11 / 10 * 11 / 9 * 11 / 8 * 11 / 7 * 11 / 6 * 11 / 5 * 11 / 4 * 11 / 3 * 11 / 2 * 11 / 1 * 11
rs# = R * EXP(-R)
rr# = 78624# * rs# * rs# * rs# * rs#
rr# = rr# * rs# * rs# * rs# * rs# * EXP(-3# * R)

ro = a(0, 0) / SQR(4 * 3.1415)
ro = ro + a(2, -2) * cnst(2, -2) * 2 * st2 * sfi * cfi
ro = ro + a(2, -1) * cnst(2, -1) * st * sfi * ct
ro = ro + a(2, 0) * cnst(2, 0) * (3 * ct2 - 1)
ro = ro + a(2, 1) * cnst(2, 1) * st * cfi * ct
ro = ro + a(2, 2) * cnst(2, 2) * st2 * (cfi * cfi - sfi * sfi)

ro = ro + a(4, -4) * cnst(4, -4) * st2 * st2 * 4 * (cfi * cfi * cfi * sfi - cfi * sfi * sfi * sfi)
ro = ro + a(4, -3) * cnst(4, -3) * ct * st * st2 * (3 * cfi * cfi * sfi - sfi * sfi * sfi)
ro = ro + a(4, -2) * cnst(4, -2) * (7 * ct2 - 1) * 2 * st2 * cfi * sfi
ro = ro + a(4, -1) * cnst(4, -1) * st * sfi * ct * (7 * ct2 - 3)
ro = ro + a(4, 0) * cnst(4, 0) * (35 * ct2 * ct2 - 30 * ct2 + 3)
ro = ro + a(4, 1) * cnst(4, 1) * st * cfi * ct * (7 * ct2 - 3)
ro = ro + a(4, 2) * cnst(4, 2) * (7 * ct2 - 1) * st2 * (cfi * cfi - sfi * sfi)
ro = ro + a(4, 3) * cnst(4, 3) * ct * st * st2 * (cfi * cfi * cfi - 3 * cfi * sfi * sfi)
ro = ro + a(4, 4) * cnst(4, 4) * st2 * st2 * (cfi * cfi * cfi * cfi - 6 * cfi * cfi * sfi * sfi + sfi * sfi * sfi * sfi)

ro = ro + a(6, -6) * cnst(6, -6) * st2 * st2 * st2 * (6 * cfi * cfi * cfi * cfi * cfi * sfi - 20 * cfi * cfi * cfi * sfi * sfi * sfi + 6 * cfi * sfi * sfi * sfi * sfi * sfi)
ro = ro + a(6, -5) * cnst(6, -5) * ct * st * st2 * st2 * (5 * cfi * cfi * cfi * cfi * sfi - 10 * cfi * cfi * sfi * sfi * sfi + sfi * sfi * sfi * sfi * sfi)
ro = ro + a(6, -4) * cnst(6, -4) * (11 * ct2 - 1) * 4 * st2 * st2 * (cfi * cfi * cfi * sfi - cfi * sfi * sfi * sfi)
ro = ro + a(6, -3) * cnst(6, -3) * (11 * ct * ct2 - 3 * ct) * st2 * st * (3 * cfi * cfi * sfi - sfi * sfi * sfi)
ro = ro + a(6, -2) * cnst(6, -2) * 2 * st2 * sfi * cfi * (16 * ct2 * ct2 - 16 * ct2 * st2 + st2 * st2)
ro = ro + a(6, -1) * cnst(6, -1) * ct * st * sfi * (33 * ct2 * ct2 - 30 * ct2 + 5)
ro = ro + a(6, 0) * cnst(6, 0) * (231 * ct2 * ct2 * ct2 - 315 * ct2 * ct2 + 105 * ct2 - 5)
ro = ro + a(6, 1) * cnst(6, 1) * ct * st * cfi * (33 * ct2 * ct2 - 30 * ct2 + 5)
ro = ro + a(6, 2) * cnst(6, 2) * (16 * ct2 * ct2 - 16 * ct2 * st2 + st2 * st2) * st2 * (cfi * cfi - sfi * sfi)
ro = ro + a(6, 3) * cnst(6, 3) * (11 * ct * ct2 - 3 * ct) * st2 * st * (cfi * cfi * cfi - 3 * cfi * sfi * sfi)
ro = ro + a(6, 4) * cnst(6, 4) * (11 * ct2 - 1) * st2 * st2 * (cfi * cfi * cfi * cfi - 6 * cfi * cfi * sfi * sfi + sfi * sfi * sfi * sfi)
ro = ro + a(6, 5) * cnst(6, 5) * ct * st * st2 * st2 * (cfi * cfi * cfi * cfi * cfi - 10 * cfi * cfi * cfi * sfi * sfi + 5 * cfi * sfi * sfi * sfi * sfi)
ro = ro + a(6, 6) * cnst(6, 6) * st2 * st2 * st2 * (cfi * cfi * cfi * cfi * cfi * cfi - 15 * cfi * cfi * cfi * cfi * sfi * sfi + 15 * cfi * cfi * sfi * sfi * sfi * sfi - sfi * sfi * sfi * sfi * sfi * sfi)
ro = ro * rr#
421 'PRINT ro
END SUB

SUB termerww (hr#(), hc#(), d%, T, en#(), cr#(), cc#(), tew#)
 REM ********************************************************************
 REM diese sub berechnet den thermischen erwartungswert tew# des hermiteschen
 REM operators hr#()+i.hc#() bei der temperatur T
 REM eingabe
 REM hr#(1..d%,1..d%)+i.hc#(1..d%.1..d%)...operatorkomponenten
 REM d%....................................dimension des zustandraums
 REM T.....................................temperatur in kelvin
 REM EN#(1..d%)............................energieeigenwerte in meV
 REM cr#(I,1..d%)+i.cc#(I,1..d%)...........eigenzustandskomponenten (I=1..d%)
 REM ausgabe:
 REM tew#..................................thermischer erwartungswert
 REM ********************************************************************
 kb# = .086173528#: REM boltzmann-konstante in meV/K

 REM berechnung der zustandssumme
 z# = 0
 FOR i = 1 TO d%
  z# = z# + EXP(-en#(i) / kb# / T)
 NEXT i

 REM berechnung des thermischen erwartungswertes
 tew# = 0
 FOR i = 1 TO d%
  REM berechnung des erwartungswertes von hr#()+i.hc#() im zustand I
  ewr# = 0: ewc# = 0
  FOR m = 1 TO d%: FOR n = 1 TO d%
   zr# = multr#(cr#(i, m), -cc#(i, m), hr#(m, n), hc#(m, n))
   zc# = multc#(cr#(i, m), -cc#(i, m), hr#(m, n), hc#(m, n))
   ewr# = ewr# + multr#(zr#, zc#, cr#(i, n), cc#(i, n))
   ewc# = ewc# + multc#(zr#, zc#, cr#(i, n), cc#(i, n))
  NEXT n: NEXT m
  IF ABS(ewc#) > 1E-10 THEN PRINT "fehler termerww: zustand"; i; "erwartungswert nicht reell!"
  'PRINT "state "; i; "-erwartungswert="; ewr#
  tew# = tew# + EXP(-en#(i) / kb# / T) / z# * ewr#
 NEXT i

END SUB

SUB viewmatrix (ar#(), ac#(), row%, col%, text$)
'this sub views matrix ar#(),ac#() of dimension row%xcol%

rl% = 1: ru% = row%
CL% = 1: cu% = col%
IF ru% > 8 THEN ru% = 8
IF cu% > 8 THEN cu% = 8


24 COLOR 12
PRINT "    "; : FOR C% = CL% TO cu%
PRINT USING "   ###   "; C%;
NEXT C%: PRINT : COLOR 15
IF rl% > 1 THEN
 COLOR 14: PRINT "    "; : FOR C% = CL% TO cu%
 PRINT "    "; CHR$(24); "    ";
 NEXT C%: COLOR 15
END IF
PRINT
FOR R% = rl% TO ru%
COLOR 12: PRINT USING "### "; R%; : COLOR 15
 FOR C% = CL% TO cu%
 IF ABS(ar#(R%, C%)) > 1E-10 THEN PRINT USING "##.##^^^^"; ar#(R%, C%);  ELSE PRINT "     0   ";
 NEXT C%: PRINT : IF CL% > 1 THEN COLOR 14: PRINT "  "; CHR$(17); " "; : COLOR 15 ELSE PRINT "    ";
 FOR C% = CL% TO cu%
 IF ABS(ac#(R%, C%)) > 1E-10 THEN PRINT USING "+#.#^^^^i"; ac#(R%, C%);  ELSE PRINT "         ";
 NEXT C%: IF cu% < col% THEN COLOR 14: PRINT CHR$(16) ELSE PRINT
IF R% < ru% THEN PRINT
NEXT R%
IF ru% < row% THEN
 PRINT "    "; : FOR C% = CL% TO cu%
 PRINT "    "; CHR$(25); "    ";
 NEXT C%: PRINT
END IF
PRINT text$;

26 WHILE a$ = "": a$ = INKEY$: WEND
IF LEN(a$) > 1 THEN
a = ASC(MID$(a$, 2))
IF a = 80 AND ru% < row% THEN ru% = ru% + 1: rl% = rl% + 1
IF a = 72 AND rl% > 1 THEN ru% = ru% - 1: rl% = rl% - 1
IF a = 77 AND cu% < col% THEN cu% = cu% + 1: CL% = CL% + 1
IF a = 75 AND CL% > 1 THEN cu% = cu% - 1: CL% = CL% - 1
a$ = "": CLS : GOTO 24
END IF
IF ASC(a$) <> 13 THEN a$ = "": GOTO 26

PRINT #9, text$: PRINT #9, "  ";
FOR i = 1 TO col%: PRINT #9, USING "    ###"; i; : NEXT i
PRINT #9,
 FOR i = 1 TO row%: PRINT #9, USING "##.#"; i;
    FOR l = 1 TO col%
     IF ABS(ar#(l, i)) > .0001 THEN PRINT #9, USING "###.###"; ar#(l, i); :               ELSE PRINT #9, "  0    ";
    NEXT l: PRINT #9, : PRINT #9, "    ";
    FOR l = 1 TO col%
     IF ABS(ac#(l, i)) > .0001 THEN PRINT #9, " +i"; : PRINT #9, USING "#.##"; ac#(l, i); :                ELSE PRINT #9, "       ";
    NEXT l: PRINT #9,
NEXT i

END SUB

