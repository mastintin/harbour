//
// $Id$
//

// This file is OK to have warnings.
#ifdef __HARBOUR__
   #pragma -es0
#else
    #TRANSLATE AS ARRAY [OF <type>] =>

    #TRANSLATE AS CHAR =>
    #TRANSLATE AS CHARACTER =>
    #TRANSLATE AS STRING =>

    #TRANSLATE AS CLASS <ClassName> =>
    #TRANSLATE AS STRU <StruName> =>
    #TRANSLATE AS STRUCTURE <StruName> =>

    #TRANSLATE AS NUM =>
    #TRANSLATE AS NUMERIC =>

    #TRANSLATE AS DATE =>
    #TRANSLATE AS BLOCK =>

    #TRANSLATE AS OBJ =>
    #TRANSLATE AS OBJECT =>

    #TRANSLATE AS BOOL =>
    #TRANSLATE AS BOOLEAN =>
    #TRANSLATE AS LOG =>
    #TRANSLATE AS LOGICAL =>

    #TRANSLATE AS VAR =>
    #TRANSLATE AS VARIANT =>

    #COMMAND DECLARE <*x*> =>
#endif

DECLARE nMyFunc( cVar AS STRING, @nVar AS NUMERIC ) AS NUMERIC

DECLARE cOtherFunc( ) AS CHAR

DECLARE cOtherFunc( @cVar as char, optional nVar as num, optional other as variant ) AS CHAR

DECLARE Seconds() AS NUM

DECLARE Int( n AS NUMERIC ) AS NUMERIC

DECLARE TEST() AS NUMERIC

DECLARE MyClass                              ;
        nMyFunc( nVal As Num ) As Num

DECLARE MyClass                              ;
        nMyFunc( nVal As Num ) As Num ;
        nMyFunc( nVal As Num ) As Num ;
        cMyData    ;
        aInstances AS Array Of Object MyClass ;
        oNext( oInstance AS Class MyClass ) As Class MyClass

DECLARE OtherClass                              ;
        nMyFunc( nVal As Num ) As Num ;
        nMyFunc( nVal As Num ) As Num ;
        cMyData    ;
        aInstances AS Array Of Object MyClass ;
        oNext( oInstance AS Class OtherClass ) As Class MyClass

FIELD a AS CHAR
FIELD b AS CHAR

MEMVAR Var1 AS CHAR

STATIC lGlobal AS LOGICAL

PROCEDURE THEMAIN( optional )

  STATIC lStatic := 0, oMyObj As Class WrongClass

  LOCAL cVar AS CHAR := [declare function]

  LOCAL a As Char, oB AS Class MyClass, c AS Char, oD AS Class OtherClass

  FIELD b AS NUM

  MEMVAR Var1 AS NUM

  PRIVATE TEST AS CHAR

  USE TEMP

  oMyObj:MyMethod( 2, 3, 4 )

  a := b:nMyFunc(2,3)
  a := b:nMyFunc(2)

  a := oB:oNext( 1 ):cMyData
  a := oB:oNext( c ):cMyData2
  a := oB:oNext( d ):cMyData
  a := oB:oNext( oD ):cMyData

  a := oB:aInstances[1]:oNext:cMyData2
  a := oB:aInstances[1]:oNext:cMyData

  x := cOtherFunc( 'A' )
  x := cOtherFunc( @Test )
  x := cOtherFunc( 'A', 'A', 'A' )

  M->TEST := "TEST"

  a := 'A'

  oB := 'a'

  if lStatic
     Var1 := .F.
  endif

  IF lGlobal
     Var1 := .T.
  ENDIF

RETURN

PROCEDURE SOMEPROC()

  PRIVATE TEST AS NUMERIC

  M->TEST := 1

  FOR M->TEST := 1 TO M->TEST + 10
    ? "Correct warnings for FOR/NEXT"
  NEXT

  REPLACE a WITH 1

  M->public_var := 0

  b := 0

  Var1 := 1

  if lGlobal = 0
     ? 'lGlobal is NOT Numeric'
  endif

RETURN

PROC MAIN1()

  PRIVATE OTHER, TEST AS CHAR

  Var1 := M->TEST

  Var2 := Test()

  ? Var1 + 2

  M->TEST := 1
  M->TEST := "No Warning"

  Test[ 1 ][ 2 ] := "Correct warning"

RETURN

Function Test()
RETURN .T.

Function Main2()
  Local n As Numeric, lVar AS LOGICAL

  n := IIF( lVar, 'A', 3 ) //IIF() needs to be completed.
  n := 2
  n := 'a'
  n := Seconds() + 2
  n := Int( seconds() + 2 )

Return( NIL )

FUNCTION Main3()

   LOCAL n AS NUMERIC, cVar AS CHARACTER, a[5,5,5] AS ARRAY OF Char

   cVar := a[1]

   n := &SomeFun( 2, 3 )

   n := ExtFun()

   cVar := cOtherFunc( 3 )

   n := nMyFunc( a, cVar ) + 3

   n := &(cVar)

   n := "&SomeVar"

   n := &Var.1

   n := V&SomeVar.1

   n[2] := 4

   cVar := {|nb AS NUMERIC , cb AS CHARACTER, db AS DATE| n := .F., nb := 'A', cb := 1, db := 0, n := 'wrong type', 0 }

   ? "This is a compiler test."

   n := 'C is Wrong Type for n'

   n := {1,2,3}

   n := a

   IIF( n, 2, 3 )

   RETURN NIL

FUNCTION SomeTest( lVar AS LOGICAL )

   LOCAL nVar AS NUMERIC, cVar AS CHARACTER, lVar2 AS LOGICAL, nNoType := 3
   PRIVATE cMemVar1 AS CHARACTER

        nVar := .T.

   nVar := 1

        nVar := 'A'

        cVar := 2

   cVar := 'B'

        cVar := 2

   lVar := .T.

     lVar := nNoType

        cVar := nVar

   M->cMemVar1 := 2

   NondDeclared := 2

   cVar := {|n AS NUMERIC , c AS CHARACTER, d AS DATE| n := nMyFunc( n,c,d ), c := 2  }

        nVar := 8 + cVar

        IF 1

   ENDIF

RETURN NIL

Function nMyFunc( cVar AS STRING, nVar AS NUMERIC )

nVar := Val(cVar)

RETURN nVar + 1

Function cOtherFunc( )
RETURN 'Hello'

Function ExtFun()
RETURN 1
