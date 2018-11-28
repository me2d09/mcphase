REM Compile bfk.f95 
REM Run this file in Intel composer 64bit command prompt

COPY bfk.f95 bfk.f90
SET VS90COMNTOOLS=%VS120COMNTOOLS%
f2py -c -m bfk bfk.f90 --fcompiler=intelvem --f90flags='-traceback'
DEL bfk.f90

