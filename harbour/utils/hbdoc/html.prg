/*
 * $Id$
 */

/*
 * Harbour Project source code:
 * HTML Support Code For FT_HELPC
 *
 * Copyright 2000 Luiz Rafael Culik <Culik@sl.conex.net>
 * www - http://www.harbour-project.org
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version, with one exception:
 *
 * The exception is that if you link the Harbour Runtime Library (HRL)
 * and/or the Harbour Virtual Machine (HVM) with other files to produce
 * an executable, this does not by itself cause the resulting executable
 * to be covered by the GNU General Public License. Your use of that
 * executable is in no way restricted on account of linking the HRL
 * and/or HVM code into it.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA (or visit
 * their web site at http://www.gnu.org/).
 *
 */

#include 'hbclass.ch'
#include 'common.ch'
#define CRLF HB_OSNewLine()
STATIC nX := 0

*+北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*+
*+    Class THTML
*+
*+北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*+
CLASS THTML

   DATA nHandle
   DATA cFile
   METHOD New( cFile ,aMetaContents)
   METHOD WriteTitle( cTitle )
   METHOD WritePar( cPar )
   METHOD WriteParBold( cPar )
   METHOD WriteLink( cLink )
   METHOD WriteText( cText )
   METHOD WriteMetaTag(cTag,cDescription)
   METHOD CLOSE()

ENDCLASS

METHOD New( cFile,aMetaContents ) CLASS THTML
    
   Local nCount
   ? Valtype(aMetaContents)
   IF Nx > 0
      FCLOSE( NX )
   ENDIF

   IF VALTYPE( cFile ) <> NIL .AND. VALTYPE( cFile ) == "C"
      Self:cFile   := LOWER( cFile )
      Self:nHandle := FCREATE( Self:cFile )
   ENDIF
   nX := Self:nHandle
   FWRITE( Self:nHandle, "<HTML>" + CRLF )
   if Valtype(aMetaContents) <> NIL .and. Valtype(aMetaContents)=="A"
   For nCount:=1 to len(aMetaContents)
      Self:WriteMetaTag(aMetaContents[nCount,1],aMetaContents[nCount,2])
   NEXT
    Endif
   FWRITE( Self:nHandle, "<BODY>" + CRLF )

RETURN Self

METHOD WriteTitle( cTitle ) CLASS THTML

   FWRITE( Self:nHandle, "<TITLE>" + CRLF + cTitle + CRLF + "</Title>" + CRLF + '</HEAD>' + CRLF + '<body bgcolor="#FFFFFF">' + CRLF )

RETURN Self

METHOD WritePar( cPar ) CLASS THTML

   //   cPar:=STRTRAN(cPar,"<","&lt;")
   //   cPar:=STRTRAN(cPar,">","&gt;")
   FWRITE( Self:nHandle, '<dd>' + ALLTRIM( cPar ) + '</dd>' + CRLF )

RETURN Self
METHOD WriteText( cPar ) CLASS THTML

   FWRITE( Self:nHandle, cPar + CRLF )

RETURN Self

METHOD WriteParBold( cPar, lEndDl, lPar ) CLASS THTML

   DEFAULT lEnddl TO .T.
   DEFAULT lPar TO .T.
   IF lEndDl .AND. lPar
      FWRITE( Self:nHandle, "</P></dd>" + CRLF + "</DL>" + CRLF + "<DL>" + CRLF + "<dt><b>" + ALLTRIM( cPar ) + '</b></dt>' + CRLF )
   ELSEIF !lPar .AND. !lEnddl
      FWRITE( Self:nHandle, '<DL>' + CRLF + "<dt><b>" + ALLTRIM( cPar ) + '</b></dt>' + CRLF )
   ELSEIF !lPar .AND. lEnddl
      FWRITE( Self:nHandle, "</PRE></dd>" + CRLF + "</DL>" + CRLF + "<DL>" + CRLF + "<dt><b>" + ALLTRIM( cPar ) + '</b></dt>' + CRLF )
   ELSEIF lPar .AND. !lEnddl
      FWRITE( Self:nHandle, "</P></dd>" + CRLF + "<DL>" + CRLF + "<dt><b>" + ALLTRIM( cPar ) + '</b></dt>' + CRLF )

   ENDIF
RETURN Self

METHOD CLOSE() CLASS THTML

   FWRITE( Self:nHandle, "</body>" + CRLF )
   FWRITE( Self:nHandle, "</html>" + CRLF )
   FCLOSE( Self:nHandle )

RETURN Self

METHOD WriteLink( cLink, cName ) CLASS THTML

   LOCAL nPos
   LOCAL cTemp := ''

   nPos := AT( "()", cLink )
   IF nPos > 0
      if AT(".htm",cLink)=0
      cTemp := SUBSTR( cLink, 1, nPos - 1 ) + '.htm'
      else
      cTemp := SUBSTR( cLink, 1, nPos - 1 )
      endif
   ELSE
         if AT(".htm",cLink)=0
      cTemp := ALLTRIM( cLink ) + '.htm'
        else
     cTemp := ALLTRIM( cLink ) 
      endif
   ENDIF
   IF cName != Nil
      cLink := cName
   ENDIF
   cTemp := STRTRAN( cTemp, " ", "" )
   FWRITE( Self:nHandle, "<LI><a href=" + LOWER( cTemp ) + ">" + cLink + "</a></LI>" + CRLF )

RETURN Self

METHOD WriteMetaTag(cTag,cDescription) Class THtml
    fWrite(Self:nHandle,'<META NAME="'+cTag+'" CONTENT="'+cDescription+'">'+CRLF)
return Self

*+ EOF: HTML.PRG
