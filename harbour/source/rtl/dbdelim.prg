/*
 * $Id$
 */

/*
 * Harbour Project source code:
 * Copies the contents of a database to a delimited text file.
 * Appends the contents of a delimited text file to a database.
 *
 * Copyright 2001 David G. Holm <dholm@jsd-llc.com>
 * www - http://www.harbour-project.org
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA (or visit the web site http://www.gnu.org/).
 *
 * As a special exception, the Harbour Project gives permission for
 * additional uses of the text contained in its release of Harbour.
 *
 * The exception is that, if you link the Harbour libraries with other
 * files to produce an executable, this does not by itself cause the
 * resulting executable to be covered by the GNU General Public License.
 * Your use of that executable is in no way restricted on account of
 * linking the Harbour library code into it.
 *
 * This exception does not however invalidate any other reasons why
 * the executable file might be covered by the GNU General Public License.
 *
 * This exception applies only to the code released by the Harbour
 * Project under the name Harbour.  If you copy code from other
 * Harbour Project or Free Software Foundation releases into a copy of
 * Harbour, as the General Public License permits, the exception does
 * not apply to the code that you add in this way.  To avoid misleading
 * anyone as to the status of such modified files, you must delete
 * this exception notice from them.
 *
 * If you write modifications of your own for Harbour, it is your choice
 * whether to permit this exception to apply to your modifications.
 * If you do not wish that, delete this exception notice.
 *
 */

#include <fileio.ch>
#include <hbclass.ch>
#include <error.ch>

/*  $DOC$
 *  $FUNCNAME$
 *      __dbDelim()
 *  $CATEGORY$
 *      Conversion
 *  $ONELINER$
 *      Copies the contents of a database to a delimited text file or
 *      appends the contents of a delimited text file to a database.
 *  $SYNTAX$
 *      __dbDelim( <lExport>, <xcFile>, [<xcDelim>], [<aFields>],
 *      [<bFor>], [<bWhile>], [<nNext>], [<nRecord>], <lRest>  ) --> NIL
 *  $ARGUMENTS$
 *      <lExport> If set to .T., copies records to a delimited file.
 *      If set to .F., append records from a delimited file.
 *      <xcFile> The name of the text file to copy to or append from.
 *      If a file extension is not specified, ".txt" is used by default.
 *      <xcDelim> Either the character to use as the character field
 *      delimiter (only the first character is used). or "BLANK" (not case
 *      sensitive), which eliminates the character field delimiters and
 *      sets the field separator to a single space instead of a comma.
 *      <aFields> An aray of field names to limit the processint to. If
 *      not specified, or if empty, then all fields are processed.
 *      <bFor> An optional code block containing a FOR expression that
 *      will reduce the number of records to be processed.
 *      <bWhile> An optional code block containing a WHILE expression
 *      that will reduce the number of records to be processed.
 *      <nNext> If present, but nRecord is not present, specifies to
 *      process this number of records, starting with the current record.
 *      A value of 0 means to process no records.
 *      <nRecord> If present, specifies the only record to process. A
 *      value of 0 means to process no records. Overrides nNext and lRest.
 *      <lRest> If lExport is .T., then if set to .T. and there are no
 *      nRecord, nNext, or bWhile arguments, processes all records from
 *      current to last.
 *  $RETURNS$
 *      NIL
 *  $DESCRIPTION$
 *      __dbDelim() copies all or selected contents of a database table
 *      to an SDF text file or appends all or selected contents of an SDF
 *      text file to a database table.
 *  $EXAMPLES$
 *      // Copy delinquent accounts into a delimited text file.
 *      USE ACCOUNTS NEW
 *      COPY TO overdue DELIMITED FOR !EMPTY( accounts->duedate ) ;
 *      .AND. DATE() - accounts->duedate > 30
 *      // Import new customer records.
 *      USE CUSTOMER NEW
 *      APPEND FROM customer DELIMITED
 *  $TESTS$
 *      
 *  $STATUS$
 *      S
 *  $COMPLIANCE$
 *      __dbDelim() is intended to be fully compliant with CA-Clipper's
 *      function of the same name and is the underlying implementation
 *      of the APPEND FROM DELIMITED and COPY TO DELIMITED commands.
 *  $PLATFORMS$
 *      All
 *  $FILES$
 *
 *  $SEEALSO$
 *      __dbSDF(), APPEND FROM, COPY TO
 *  $END$
 */

FUNCTION __dbDelim( lExport, cFile, cDelimArg, aFields, bFor, bWhile, nNext, nRecord, lRest )
   LOCAL index, handle, lWriteSep, cFileName := cFile, nStart, nCount, oErr
   LOCAL cSeparator := ",", cDelim := CHR( 34 )

   // Process the delimiter argument.
   IF !EMPTY( cDelimArg )
      IF UPPER( cDelimArg ) == "BLANK"
         cDelim := ""
         cSeparator := " "
      ELSE
         cDelim := LEFT( cDelimArg, 1 )
      END IF
   END IF

   // Process the file name argument.
   index := RAT( ".", cFileName )
   IF index > 0
      // The file name might include a file extension.
      IF RAT( "/", cFileName ) > index ;
      .OR. RAT( "\", cFileName ) > index
         // No, the file extension is in a directory name.
         index := 0
      END IF
   END IF
   IF index <= 0
      // No file name extension, so provide the default.
      cFileName += ".txt"
   END IF

   // Determine where to start and how many records to process.
   IF nRecord != NIL
      // The RECORD clause has the highest priority.
      nStart := nRecord
      nCount := 1
   ELSEIF nNext != NIL
      // The NEXT clause has the next highest priority.
      nStart := -1
      nCount := nNext
   ELSEIF bWhile != NIL .OR. lRest
      // The WHILE and REST clauses have equal priority.
      nStart := -1
      nCount := -1
   ELSE
      // Followed by the FOR clause or the ALL clause.
      nStart := 0
      nCount := -1
   END IF
   IF EMPTY( bFor )
      // This simplifies the test that determines whether or not to
      // use (i.e., import or export) any given processed record.
      bFor := {||.T.}
   END IF

   IF lExport
      // COPY TO DELIMITED
      handle := FCREATE( cFileName )
      IF handle == -1
         oErr := ErrorNew()
         oErr:severity := ES_ERROR
         oErr:genCode := EG_CREATE
         oErr:subSystem := "DELIM"
         oErr:subCode := 1002
         oErr:description := HB_LANGERRMSG( oErr:genCode )
         oErr:canRetry := .T.
         oErr:canDefault := .T.
         oErr:fileName := cFileName
         oErr:osCode := FERROR()
         Eval(ErrorBlock(), oErr)
      ELSE
         IF nStart > -1
            // Only reposition if a starting record was specified or implied.
            IF nStart == 0
               GO TOP
            ELSE
               GO (nStart)
            END IF
         END IF
         IF EMPTY( bWhile )
            // This simplifies the looping logic.
            bWhile := {||!BOF().AND.!EOF()}
         END IF
         // Set up for the start of the first record.
         lWriteSep := .F.
         // Process the records to copy delimited.
         WHILE EVAL( bWhile ) .AND. ( nCount == -1 .OR. nCount > 0 )
            IF EVAL( bFor )
               IF EMPTY( aFields )
                  // Process all fields.
                  FOR index := 1 TO FCOUNT()
                     IF lWriteSep
                        AppendSep( handle, cSeparator )
                     END IF
                     lWriteSep := ExportVar( handle, FIELDGET( index ), cDelim )
                  NEXT index
               ELSE
                  // Process the specified fields.
                  FOR index := 1 TO LEN( aFields )
                     IF lWriteSep
                        AppendSep( handle, cSeparator )
                     END IF
                     lWriteSep := ExportVar( handle, FIELDGET( FIELDPOS( aFields[ index ] ) ), cDelim )
                  NEXT index
               END IF
               // Set up for the start of the next record.
               AppendEOL( handle )
               lWriteSep := .F.
            END IF
            IF nCount != -1
               nCount--
            END IF
            SKIP
         END WHILE
         AppendEOF( handle )
         FCLOSE( handle )
      END IF
   ELSE
      // APPEND FROM DELIMITED
      handle := FOPEN( cFileName )
      IF handle == -1
         oErr := ErrorNew()
         oErr:severity := ES_ERROR
         oErr:genCode := EG_OPEN
         oErr:subSystem := "DELIM"
         oErr:subCode := 1001
         oErr:description := HB_LANGERRMSG( oErr:genCode )
         oErr:canRetry := .T.
         oErr:canDefault := .T.
         oErr:fileName := cFileName
         oErr:osCode := FERROR()
         Eval(ErrorBlock(), oErr)
      ELSE
         IF EMPTY( bWhile )
            // This simplifies the looping logic.
            bWhile := {||.T.}
         END IF
         FCLOSE( handle )
      END IF
   END IF
RETURN NIL

STATIC FUNCTION ExportVar( handle, xField, cDelim )
   LOCAL cText := "", lWrite := .F.
   DO CASE
      CASE VALTYPE( xField ) == "C"
         cText := cDelim + TRIM( xField ) + cDelim
         lWrite := .T.
      CASE VALTYPE( xField ) == "D"
         cText := DTOS( xField )
         lWrite := .T.
      CASE VALTYPE( xField ) == "L"
         cText := IF( xField, "T", "F" )
         lWrite := .T.
      CASE VALTYPE( xField ) == "N"
         cText := LTRIM( STR( xField ) )
         lWrite := .T.
   END CASE
   FWRITE( handle, cText )
RETURN lWrite

STATIC FUNCTION AppendEOL( handle )
   STATIC cEOL := CHR( 13 ) + CHR( 10 )
RETURN FWRITE( handle, cEOL )

STATIC FUNCTION AppendEOF( handle )
   STATIC cEOF := CHR( 26 )
RETURN FWRITE( handle, cEOF )

STATIC FUNCTION AppendSep( handle, cSep )
RETURN FWRITE( handle, cSep )
