DECLARE SUB inputline (n!, d1#(), col1%, d2$(), col2%)
DECLARE SUB checkrepeat (file1$)
DECLARE SUB headerinput (text$(), j!, n!)
PRINT "CUTHEAD CUTHEAD CUTHEAD CUTHEAD CUTHEAD CUTHEAD CUTHEAD CUTHEAD CUTHEAD"
IF LTRIM$(COMMAND$) = "" GOTO 333
DATA "*************************************************************************"
DATA "  program CUTHEAD - use it like CUTHEAD *.* 10 [/r]                         "
DATA "    (means cut header to 10 lines in file *.*) -                              "
DATA "    option /r means delete header if there are no data points        "
DATA "format of file"
DATA " { header: this is the                                                  "
DATA "   file header delimited                                                "
DATA "   by brackets after this header there follow 3 or more data columns }  "
DATA " 11 3.14235 65367                                                       "
DATA "  .    .     .                                                          "
DATA "  .    .     .                                                          "
DATA "  .    .     .    .  .   .                                              "
DATA "  .    .     .                                                          "
DATA " 32 2412.34 324.2                                                       "
DATA ""
DATA "*************************************************************************"
DIM text$(300), xm#(30), d2$(30)

' analyse command string aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
a$ = LCASE$(LTRIM$(RTRIM$(COMMAND$)))
filename$ = RTRIM$(LEFT$(a$, INSTR(a$, " "))): a$ = LTRIM$(RIGHT$(a$, LEN(a$) - INSTR(a$, " ")))
jj% = VAL(a$) MOD 48 'lines to leave

999 CALL checkrepeat(filename$)

IF RIGHT$(filename$, 4) = ".rcp" OR RIGHT$(filename$, 4) = ".mrc" THEN
   PRINT "you should never ever change data in *.rcp/mrc files": PLAY "dgdgdg"
222 INPUT "do you really want to continue (Y/N)"; ala$: IF LCASE$(ala$) = "n" THEN END
   IF LCASE$(ala$) <> "y" GOTO 222
END IF
'Aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa

'open input file and input file header
OPEN "i", 1, filename$
' open output file
OPEN "o", 2, "CUTHEAD.cut"

22 j = jj%: CALL headerinput(text$(), j, 1)
IF j < jj% THEN jj% = j

 IF EOF(1) = 0 THEN
  CALL inputline(1, xm#(), col%, d2$(), col2%)
 ELSE
  GOTO 23
 END IF

 IF col% > -1 OR INSTR(LCASE$(COMMAND$), "/r") = 0 THEN 'printout header
  IF jj% > 0 THEN
   PRINT #2, "{"; : FOR iii = 1 TO jj% - 1: PRINT #2, text$(iii): NEXT
   PRINT #2, text$(jj%); DATE$; " "; TIME$; "textcut}"
  END IF
 END IF
 IF col% = -1 GOTO 22

'write result to file
IF col% > 0 OR col2% > 0 THEN
 FOR coll% = 1 TO col%: PRINT #2, xm#(coll%); : NEXT
 FOR coll% = 1 TO col2%: PRINT #2, "{"; d2$(coll%); "}"; : NEXT: PRINT #2,
END IF
 REM input data columns
WHILE EOF(1) = 0
 CALL inputline(1, xm#(), col%, d2$(), col2%)
 IF col% = -1 GOTO 22
'write result to file
IF col% > 0 OR col2% > 0 THEN
 FOR coll% = 1 TO col%
nn$ = STR$(xm#(coll%)): IF INSTR(nn$, "D") > 0 THEN MID$(nn$, INSTR(nn$, "D"), 1) = "E"
PRINT #2, " " + nn$;
NEXT
 FOR coll% = 1 TO col2%: PRINT #2, "{"; d2$(coll%); "}"; : NEXT: PRINT #2,
END IF

WEND

23 CLOSE 1, 2
SHELL "copy CUTHEAD.cut " + filename$
SHELL "del CUTHEAD.cut"

PRINT
PRINT "END CUTHEAD in file "; filename$; "header has been cut"

IF INSTR(COMMAND$, "*") <> 0 GOTO 999
END

333 FOR i = 1 TO 16: READ a$: PRINT a$: NEXT i: END

SUB checkrepeat (file1$)
STATIC washere%

  IF INSTR(COMMAND$, "*") <> 0 THEN  'this is for cumulative action on more files
   IF washere% = 0 THEN
      washere% = 1
      'get filenames to be operated on as file1$
      SHELL "dir " + file1$ + " /b > fact.dir"
      OPEN "i", 9, "fACT.dir"
   END IF
   IF EOF(9) <> 0 THEN CLOSE 9: SHELL "del fact.dir": END
   INPUT #9, file1$
   IF LCASE$(file1$) = "fact.dir" THEN
    IF EOF(9) <> 0 THEN CLOSE 9: SHELL "del fact.dir": END
    INPUT #9, file1$
   END IF
   IF LTRIM$(file1$) = "" THEN CLOSE 9: SHELL "del fact.dir": END
  END IF

END SUB

SUB headerinput (text$(), j, n)
'**********************************************************************
' input file header of measurement file opened with #n
' the file header inputted has then j lines and is stored in text$(1-j)
'**********************************************************************
   jj% = j
1 INPUT #n, a$
   i = INSTR(a$, "{"): IF i > 0 GOTO 2 ELSE GOTO 1     'look for "{"
2 text$(1) = RIGHT$(a$, LEN(a$) - i)
  j = 1: i = INSTR(text$(j), "}"): IF i > 0 GOTO 3  'look for "}" in first line
                                           
   FOR j = 2 TO jj%
   INPUT #n, text$(j)
   i = INSTR(text$(j), "}"): IF i > 0 GOTO 3      'look for "}"
   NEXT j: i = LEN(text$(jj%))
    WHILE EOF(1) = 0 AND ii = 0: INPUT #n, t$: ii = INSTR(t$, "}"): WEND
  
   IF EOF(1) = 1 THEN PRINT "no } in data file": END
3 text$(j) = LEFT$(text$(j), i - 1)

END SUB

SUB inputline (n, d1#(), col1%, d2$(), col2%)
'input data point line on #n as string and split into numbers
' determine col1% and save data columns in d1#(1...col1%)
'comments in {} are stored in comment$
'if a comment is started somewhere in this line by "{" and not finished
'then col1% is set -1

a$ = INKEY$: IF a$ <> "" THEN IF ASC(a$) = 27 THEN END
' IF SCREEN(24, 10) <> 45 THEN PRINT "-";  ELSE LOCATE 24, 1: PRINT SPACE$(15); : LOCATE 24, 1
PRINT USING "-###%"; 100 * SEEK(n) / LOF(n); : LOCATE 24, 1
'PRINT USING "-########"; SEEK(n); : LOCATE 24, 1

aa = SEEK(n)
LINE INPUT #n, ala$
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

