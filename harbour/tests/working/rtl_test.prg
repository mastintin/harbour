/*
 * $Id$
 */

/*
   Harbour Project source code

   Runtime library regression tests, currently for some of the
   string manipulating functions.

   Copyright (C) 1999  Victor Szel <info@szelvesz.hu>
   www - http://www.harbour-project.org

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version, with one exception:

   The exception is that if you link the Harbour Runtime Library (HRL)
   and/or the Harbour Virtual Machine (HVM) with other files to produce
   an executable, this does not by itself cause the resulting executable
   to be covered by the GNU General Public License. Your use of that
   executable is in no way restricted on account of linking the HRL
   and/or HVM code into it.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA (or visit
   their web site at http://www.gnu.org/).
*/

/* TODO: Add checks for string parameters with embedded NUL character */
/* TODO: Add test cases for other string functions */
/* TODO: Incorporate tests from test/working/string*.prg */

#translate TEST_LINE(<x>, <result>) => TEST_CALL(<(x)>, {|| <x> }, <result>)

STATIC snPass := 0
STATIC snFail := 0

FUNCTION Main()

     /* AT() */

     TEST_LINE( At("", "")                    , 1                )
     TEST_LINE( At("", "ABCDEF")              , 1                )
     TEST_LINE( At("ABCDEF", "")              , 0                )
     TEST_LINE( At("AB", "AB")                , 1                )
     TEST_LINE( At("AB", "AAB")               , 2                )
     TEST_LINE( At("A", "ABCDEF")             , 1                )
     TEST_LINE( At("F", "ABCDEF")             , 6                )
     TEST_LINE( At("D", "ABCDEF")             , 4                )
     TEST_LINE( At("X", "ABCDEF")             , 0                )
     TEST_LINE( At("AB", "ABCDEF")            , 1                )
     TEST_LINE( At("AA", "ABCDEF")            , 0                )
     TEST_LINE( At("ABCDEF", "ABCDEF")        , 1                )
     TEST_LINE( At("BCDEF", "ABCDEF")         , 2                )
     TEST_LINE( At("BCDEFG", "ABCDEF")        , 0                )
     TEST_LINE( At("ABCDEFG", "ABCDEF")       , 0                )
     TEST_LINE( At("FI", "ABCDEF")            , 0                )

     /* RAT() */

     TEST_LINE( RAt("", "")                   , 0                )
     TEST_LINE( RAt("", "ABCDEF")             , 0                )
     TEST_LINE( RAt("ABCDEF", "")             , 0                )
     TEST_LINE( RAt("AB", "AB")               , 1                )
     TEST_LINE( RAt("AB", "AAB")              , 2                )
     TEST_LINE( RAt("AB", "ABAB")             , 3                )
     TEST_LINE( RAt("A", "ABCADEF")           , 4                )
     TEST_LINE( RAt("A", "ABCADEFA")          , 8                )
     TEST_LINE( RAt("A", "ABCDEFA")           , 7                )
     TEST_LINE( RAt("A", "ABCDEF")            , 1                )
     TEST_LINE( RAt("F", "ABCDEF")            , 6                )
     TEST_LINE( RAt("D", "ABCDEF")            , 4                )
     TEST_LINE( RAt("X", "ABCDEF")            , 0                )
     TEST_LINE( RAt("AB", "ABCDEF")           , 1                )
     TEST_LINE( RAt("AA", "ABCDEF")           , 0                )
     TEST_LINE( RAt("ABCDEF", "ABCDEF")       , 1                )
     TEST_LINE( RAt("BCDEF", "ABCDEF")        , 2                )
     TEST_LINE( RAt("BCDEFG", "ABCDEF")       , 0                )
     TEST_LINE( RAt("ABCDEFG", "ABCDEF")      , 0                )
     TEST_LINE( RAt("FI", "ABCDEF")           , 0                )

     /* SUBSTR() */

     TEST_LINE( SubStr("abcdef", 0, -1)       , ""               )
     TEST_LINE( SubStr("abcdef", 0, 0)        , ""               )
     TEST_LINE( SubStr("abcdef", 0, 1)        , "a"              )
     TEST_LINE( SubStr("abcdef", 0, 7)        , "abcdef"         )
     TEST_LINE( SubStr("abcdef", 0)           , "abcdef"         )
     TEST_LINE( SubStr("abcdef", 2, -1)       , ""               )
     TEST_LINE( SubStr("abcdef", 2, 0)        , ""               )
     TEST_LINE( SubStr("abcdef", 2, 1)        , "b"              )
     TEST_LINE( SubStr("abcdef", 2, 7)        , "bcdef"          )
     TEST_LINE( SubStr("abcdef", 2)           , "bcdef"          )
     TEST_LINE( SubStr("abcdef", -2, -1)      , ""               )
     TEST_LINE( SubStr("abcdef", -2, 0)       , ""               )
     TEST_LINE( SubStr("abcdef", -2, 1)       , "e"              )
     TEST_LINE( SubStr("abcdef", -2, 7)       , "ef"             )
     TEST_LINE( SubStr("abcdef", -2)          , "ef"             )
     TEST_LINE( SubStr("abcdef", 10, -1)      , ""               )
     TEST_LINE( SubStr("abcdef", 10, 0)       , ""               )
     TEST_LINE( SubStr("abcdef", 10, 1)       , ""               )
     TEST_LINE( SubStr("abcdef", 10, 7)       , ""               )
     TEST_LINE( SubStr("abcdef", 10)          , ""               )
     TEST_LINE( SubStr("abcdef", -10, -1)     , ""               )
     TEST_LINE( SubStr("abcdef", -10, 0)      , ""               )
     TEST_LINE( SubStr("abcdef", -10, 1)      , "a"              )
     TEST_LINE( SubStr("abcdef", -10, 7)      , "abcdef"         )
     TEST_LINE( SubStr("abcdef", -10, 15)     , "abcdef"         )
     TEST_LINE( SubStr("abcdef", -10)         , "abcdef"         )
     TEST_LINE( SubStr("ab" + Chr(0) + "def", 2, 3) , "b" + Chr(0) + "d"   )

     /* LEFT() */

     TEST_LINE( Left("abcdef", -10)           , ""               )
     TEST_LINE( Left("abcdef", -2)            , ""               )
     TEST_LINE( Left("abcdef", 0)             , ""               )
     TEST_LINE( Left("abcdef", 2)             , "ab"             )
     TEST_LINE( Left("abcdef", 10)            , "abcdef"         )
     TEST_LINE( Left("ab" + Chr(0) + "def", 5)      , "ab" + Chr(0) + "de" )

     /* RIGHT() */

     TEST_LINE( Right("abcdef", -10)          , ""               )
     TEST_LINE( Right("abcdef", -2)           , ""               )
     TEST_LINE( Right("abcdef", 0)            , ""               )
     TEST_LINE( Right("abcdef", 2)            , "ef"             )
     TEST_LINE( Right("abcdef", 10)           , "abcdef"         )
     TEST_LINE( Right("ab" + Chr(0) + "def", 5)     , "b" + Chr(0) + "def" )

     /* PADR() */

     TEST_LINE( PadR(NIL, 5)                  , ""               )
     TEST_LINE( PadR(.T., 5)                  , ""               )
     TEST_LINE( PadR(10, 5)                   , "10   "          )
     TEST_LINE( PadR("abcdef", -5)            , ""               )
     TEST_LINE( PadR("abcdef", 0)             , ""               )
     TEST_LINE( PadR("abcdef", 5)             , "abcde"          )
     TEST_LINE( PadR("abcdef", 10)            , "abcdef    "     )
     TEST_LINE( PadR("abcdef", 10, "1")       , "abcdef1111"     )
     TEST_LINE( PadR("abcdef", 10, "12")      , "abcdef1111"     )

     /* PADL() */

     TEST_LINE( PadL(NIL, 5)                  , ""               )
     TEST_LINE( PadL(.T., 5)                  , ""               )
     TEST_LINE( PadL(10, 5)                   , "   10"          )
     TEST_LINE( PadL("abcdef", -5)            , ""               )
     TEST_LINE( PadL("abcdef", 0)             , ""               )
     TEST_LINE( PadL("abcdef", 5)             , "abcde"          ) /* QUESTION: CA-Cl*pper "bug", should return: "bcdef" ? */
     TEST_LINE( PadL("abcdef", 10)            , "    abcdef"     )
     TEST_LINE( PadL("abcdef", 10, "1")       , "1111abcdef"     )
     TEST_LINE( PadL("abcdef", 10, "12")      , "1111abcdef"     )

     /* PADC() */

     TEST_LINE( PadC(NIL, 5)                  , ""               )
     TEST_LINE( PadC(.T., 5)                  , ""               )
     TEST_LINE( PadC(10, 5)                   , " 10  "          )
     TEST_LINE( PadC("abcdef", -5)            , ""               )
     TEST_LINE( PadC("abcdef", 0)             , ""               )
     TEST_LINE( PadC("abcdef", 2)             , "ab"             ) /* QUESTION: CA-Cl*pper "bug", should return: "cd" ? */
     TEST_LINE( PadC("abcdef", 5)             , "abcde"          )
     TEST_LINE( PadC("abcdef", 10)            , "  abcdef  "     )
     TEST_LINE( PadC("abcdef", 10, "1")       , "11abcdef11"     )
     TEST_LINE( PadC("abcdef", 10, "12")      , "11abcdef11"     )

     TEST_LINE( Stuff("ABCDEF", 0, 0, NIL)    , ""               )
     TEST_LINE( Stuff("ABCDEF", 0, 0, "xyz")  , "xyzABCDEF"      )
     TEST_LINE( Stuff("ABCDEF", 1, 0, "xyz")  , "xyzABCDEF"      )
     TEST_LINE( Stuff("ABCDEF", 2, 0, "xyz")  , "AxyzBCDEF"      )
     TEST_LINE( Stuff("ABCDEF", 2, 3, "xyz")  , "AxyzEF"         )
     TEST_LINE( Stuff("ABCDEF", 2, 2, "")     , "ADEF"           )
     TEST_LINE( Stuff("ABCDEF", 2, 1, "xyz")  , "AxyzCDEF"       )
     TEST_LINE( Stuff("ABCDEF", 2, 4, "xyz")  , "AxyzF"          )
     TEST_LINE( Stuff("ABCDEF", 2, 10, "xyz") , "Axyz"           )

#ifdef __HARBOUR__

     /* __COLORINDEX() */

     TEST_LINE( __ColorIndex()                  , ""               )
     TEST_LINE( __ColorIndex("", -1)            , ""               )
     TEST_LINE( __ColorIndex("", 0)             , ""               )
     TEST_LINE( __ColorIndex("W/R", -1)         , ""               )
     TEST_LINE( __ColorIndex("W/R", 0)          , "W/R"            )
     TEST_LINE( __ColorIndex("W/R", 1)          , ""               )
     TEST_LINE( __ColorIndex("W/R", 2)          , ""               )
     TEST_LINE( __ColorIndex("W/R,GR/0", 0)     , "W/R"            )
     TEST_LINE( __ColorIndex("W/R,GR/0", 1)     , "GR/0"           )
     TEST_LINE( __ColorIndex("W/R,GR/0", 2)     , ""               )
     TEST_LINE( __ColorIndex("W/R,GR/0", 3)     , ""               )
     TEST_LINE( __ColorIndex("W/R, GR/0", 0)    , "W/R"            )
     TEST_LINE( __ColorIndex("W/R, GR/0", 1)    , "GR/0"           )
     TEST_LINE( __ColorIndex("W/R, GR/0", 2)    , ""               )
     TEST_LINE( __ColorIndex("W/R, GR/0", 3)    , ""               )
     TEST_LINE( __ColorIndex("W/R,GR/0 ", 0)    , "W/R"            )
     TEST_LINE( __ColorIndex("W/R,GR/0 ", 1)    , "GR/0"           )
     TEST_LINE( __ColorIndex("W/R,GR/0 ", 2)    , ""               )
     TEST_LINE( __ColorIndex("W/R, GR/0 ", 0)   , "W/R"            )
     TEST_LINE( __ColorIndex("W/R, GR/0 ", 1)   , "GR/0"           )
     TEST_LINE( __ColorIndex("W/R, GR/0 ", 2)   , ""               )
     TEST_LINE( __ColorIndex("W/R, GR/0 ,", 0)  , "W/R"            )
     TEST_LINE( __ColorIndex("W/R, GR/0 ,", 1)  , "GR/0"           )
     TEST_LINE( __ColorIndex("W/R, GR/0 ,", 2)  , ""               )
     TEST_LINE( __ColorIndex(" W/R, GR/0 ,", 0) , "W/R"            )
     TEST_LINE( __ColorIndex(" W/R, GR/0 ,", 1) , "GR/0"           )
     TEST_LINE( __ColorIndex(" W/R, GR/0 ,", 2) , ""               )
     TEST_LINE( __ColorIndex(" W/R , GR/0 ,", 0), "W/R"            )
     TEST_LINE( __ColorIndex(" W/R , GR/0 ,", 1), "GR/0"           )
     TEST_LINE( __ColorIndex(" W/R , GR/0 ,", 2), ""               )
     TEST_LINE( __ColorIndex(" W/R ,   ,", 1)   , ""               )
     TEST_LINE( __ColorIndex(" W/R ,,", 1)      , ""               )
     TEST_LINE( __ColorIndex(",,", 0)           , ""               )
     TEST_LINE( __ColorIndex(",,", 1)           , ""               )
     TEST_LINE( __ColorIndex(",,", 2)           , ""               )
     TEST_LINE( __ColorIndex(",  ,", 2)         , ""               )

#endif

     /* Show results, return ERRORLEVEL and exit */

     TEST_STAT()

     RETURN NIL

STATIC FUNCTION TEST_CALL(cBlock, bBlock, xResultExpected)
     LOCAL xResult := Eval(bBlock)

     fWrite(1, PadR(StrTran(cBlock, Chr(0), "."), 40) + " -> " +;
               PadR('"' + StrTran(XToStr(xResult), Chr(0), ".") + '"', 15) + " " +;
               PadR('"' + StrTran(XToStr(xResultExpected), Chr(0), ".") + '"', 15))

     IF xResult == xResultExpected
          snPass++
     ELSE
          fWrite(1, "! *FAIL* !")
          snFail++
     ENDIF

     fWrite(1, Chr(13) + Chr(10))

     RETURN NIL

STATIC FUNCTION TEST_STAT()

     fWrite(1, Chr(13) + Chr(10) +;
               "Test calls passed: " + Str(snPass) + Chr(13) + Chr(10) +;
               "Test calls failed: " + Str(snFail) + Chr(13) + Chr(10))

     ErrorLevel(iif(snFail != 0, 1, 0))

     RETURN NIL

STATIC FUNCTION XToStr(xValue)
     LOCAL cType := ValType(xValue)

     DO CASE
     CASE cType == "C" ; RETURN xValue
     CASE cType == "N" ; RETURN LTrim(Str(xValue))
     CASE cType == "D" ; RETURN DToC(xValue)
     CASE cType == "L" ; RETURN iif(xValue, ".T.", ".F.")
     CASE cType == "O" ; RETURN xValue:className + " Object"
     CASE cType == "U" ; RETURN "NIL"
     CASE cType == "B" ; RETURN "{||...}"
     CASE cType == "A" ; RETURN "{...}"
     CASE cType == "M" ; RETURN xValue
     ENDCASE

     RETURN ""
