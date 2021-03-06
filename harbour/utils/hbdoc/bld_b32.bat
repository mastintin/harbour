@echo off
rem
rem $Id$
rem

..\..\bin\harbour -w3 -q -n -km -l -i..\..\include hbdoc ft_funcs genasc genchm genhpc genhtm genng genos2 genpdf1 genrtf gentrf

echo -O2 -I..\..\include -L..\..\lib > build.tmp

echo hbdoc.c      >> build.tmp
echo ft_funcs.c   >> build.tmp
echo genasc.c     >> build.tmp
echo genchm.c     >> build.tmp
echo genhpc.c     >> build.tmp
echo genhtm.c     >> build.tmp
echo genng.c      >> build.tmp
echo genos2.c     >> build.tmp
echo genpdf1.c    >> build.tmp
echo genrtf.c     >> build.tmp
echo gentrf.c     >> build.tmp

echo hbdfrdln.c   >> build.tmp

echo hbvm.lib     >> build.tmp
echo hbrtl.lib    >> build.tmp
echo gtwin.lib    >> build.tmp
echo hbnulrdd.lib >> build.tmp
echo hbmacro.lib  >> build.tmp
echo hbcommon.lib >> build.tmp

bcc32 @build.tmp
del build.tmp

del *.obj
del hbdoc.c ft_funcs.c genasc.c genchm.c genhpc.c genhtm.c genng.c genos2.c genpdf1.c genrtf.c gentrf.c
