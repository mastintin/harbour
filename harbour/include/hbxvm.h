/*
 * $Id$
 */

/*
 * Harbour Project source code:
 * Header file for the Internal Terminal API
 *
 * Copyright 2006 Przemyslaw Czerpak < druzus /at/ priv.onet.pl >
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

/* NOTE: The declaration of hb_gtSetPos(), hb_gtGetPos(), hb_gtWrite(),
         hb_gtWriteAt(), hb_gtRepChar(), hb_gtBox(), hb_gtBoxS(), hb_gtBoxD() 
         hb_gtInit() differs in parameter types from the original CA-Cl*pper 
         versions. [vszakats] */

#ifndef HB_XVM_H_
#define HB_XVM_H_

#include "hbapi.h"
#include "hbapiitm.h"
#include "hbvm.h"
#include "hbstack.h"

HB_EXTERN_BEGIN

/*
 * Functions below which return BOLL value can cause error handler
 * executing so we have to check for break request flag. The return
 * value is TRUE when break request is set.
 * other functions does not execute error handler and we do not have
 * to check HVM state so they are simply declared as void.
 */

extern HB_EXPORT void   hb_xvmExitProc( void );
extern HB_EXPORT void   hb_xvmEndProc( void );
extern HB_EXPORT void   hb_xvmSeqBegin( void );
extern HB_EXPORT BOOL   hb_xvmSeqEnd( void );
extern HB_EXPORT BOOL   hb_xvmSeqEndTest( void );
extern HB_EXPORT BOOL   hb_xvmSeqRecover( void );
extern HB_EXPORT void   hb_xvmSeqAlways( void );
extern HB_EXPORT BOOL   hb_xvmAlwaysBegin( void );
extern HB_EXPORT BOOL   hb_xvmAlwaysEnd( void );
extern HB_EXPORT BOOL   hb_xvmSeqBlock( void );

extern HB_EXPORT BOOL   hb_xvmEnumStart( BYTE, BYTE );            /* prepare FOR EACH loop */
extern HB_EXPORT BOOL   hb_xvmEnumNext( void );                   /* increment FOR EACH loop counter */
extern HB_EXPORT BOOL   hb_xvmEnumPrev( void );                   /* decrement FOR EACH loop counter */
extern HB_EXPORT void   hb_xvmEnumEnd( void );                    /* rewind the stack after FOR EACH loop counter */

extern HB_EXPORT void   hb_xvmWithObjectStart( void );            /* prepare WITH OBJECT statement */
extern HB_EXPORT void   hb_xvmWithObjectEnd( void );              /* rewind the stack after normal WITH OBJECT */
extern HB_EXPORT void   hb_xvmWithObjectMessage( PHB_SYMB );      /* send WITH OBJECT message to current WITH OBJECT control variable */

extern HB_EXPORT void   hb_xvmSetLine( USHORT uiLine );           /* set .prg line number information */

extern HB_EXPORT void   hb_xvmFrame( int iLocals, int iParams );  /* increases the stack pointer for the amount of locals and params suplied */
extern HB_EXPORT void   hb_xvmVFrame( int iLocals, int iParams ); /* increases the stack pointer for the amount of locals and variable params */
extern HB_EXPORT void   hb_xvmSFrame( PHB_SYMB pSymbol );
extern HB_EXPORT void   hb_xvmStatics( PHB_SYMB pSymbol, USHORT uiStatics );
extern HB_EXPORT void   hb_xvmThreadStatics( USHORT uiStatics, const BYTE * statics );
extern HB_EXPORT void   hb_xvmParameter( PHB_SYMB pSymbol, int iParams );
extern HB_EXPORT void   hb_xvmRetValue( void );                   /* pops the latest stack value into stack.Return */
extern HB_EXPORT BOOL   hb_xvmDo( USHORT uiParams );
extern HB_EXPORT BOOL   hb_xvmFunction( USHORT uiParams );
extern HB_EXPORT BOOL   hb_xvmSend( USHORT uiParams );
extern HB_EXPORT BOOL   hb_xvmPushObjectVarRef( void );
extern HB_EXPORT void   hb_xvmPushStatic( USHORT uiStatic );
extern HB_EXPORT void   hb_xvmPushStaticByRef( USHORT uiStatic );
extern HB_EXPORT void   hb_xvmPopStatic( USHORT uiStatic );
extern HB_EXPORT BOOL   hb_xvmPushVariable( PHB_SYMB pSymbol );
extern HB_EXPORT BOOL   hb_xvmPopVariable( PHB_SYMB pSymbol );
extern HB_EXPORT void   hb_xvmPushBlock( const BYTE * pCode, PHB_SYMB pSymbols ); /* creates a codeblock */
extern HB_EXPORT void   hb_xvmPushBlockShort( const BYTE * pCode, PHB_SYMB pSymbols ); /* creates a codeblock */
extern HB_EXPORT void   hb_xvmPushBlockLarge( const BYTE * pCode, PHB_SYMB pSymbols ); /* creates a codeblock */
extern HB_EXPORT void   hb_xvmPushSelf( void );
extern HB_EXPORT void   hb_xvmPushVParams( void );
extern HB_EXPORT void   hb_xvmPushLocal( SHORT iLocal );          /* pushes the containts of a local onto the stack */
extern HB_EXPORT void   hb_xvmPushLocalByRef( SHORT iLocal );     /* pushes a local by refrence onto the stack */
extern HB_EXPORT void   hb_xvmPopLocal( SHORT iLocal );           /* pops the stack latest value onto a local */
extern HB_EXPORT BOOL   hb_xvmPushField( PHB_SYMB pSymbol );
extern HB_EXPORT BOOL   hb_xvmPopField( PHB_SYMB pSymbol );
extern HB_EXPORT BOOL   hb_xvmPushMemvar( PHB_SYMB pSymbol );
extern HB_EXPORT BOOL   hb_xvmPushMemvarByRef( PHB_SYMB pSymbol );
extern HB_EXPORT BOOL   hb_xvmPopMemvar( PHB_SYMB pSymbol );
extern HB_EXPORT BOOL   hb_xvmPushAliasedField( PHB_SYMB pSymbol );
extern HB_EXPORT BOOL   hb_xvmPopAliasedField( PHB_SYMB pSymbol );
extern HB_EXPORT BOOL   hb_xvmPushAliasedVar( PHB_SYMB pSymbol );
extern HB_EXPORT BOOL   hb_xvmPopAliasedVar( PHB_SYMB pSymbol );
extern HB_EXPORT BOOL   hb_xvmPushAlias( void );
extern HB_EXPORT BOOL   hb_xvmPopAlias( void );                   /* select the workarea using a given item or a substituted value */
extern HB_EXPORT BOOL   hb_xvmPopLogical( BOOL * );               /* pops the stack latest value and returns its logical value */
extern HB_EXPORT BOOL   hb_xvmSwapAlias( void );                  /* swaps items on the eval stack and pops the workarea number */
extern HB_EXPORT BOOL   hb_xvmLocalAddInt( int iLocal, LONG lAdd ); /* add integer to given local variable */
extern HB_EXPORT BOOL   hb_xvmLocalInc( int iLocal );             /* increment given local variable */
extern HB_EXPORT BOOL   hb_xvmLocalDec( int iLocal );             /* decrement given local variable */
extern HB_EXPORT BOOL   hb_xvmLocalIncPush( int iLocal );         /* increment given local variable and pussh it on HVM stack */

extern HB_EXPORT BOOL   hb_xvmAnd( void );
extern HB_EXPORT BOOL   hb_xvmOr( void );
extern HB_EXPORT BOOL   hb_xvmNot( void );
extern HB_EXPORT BOOL   hb_xvmNegate( void );
extern HB_EXPORT void   hb_xvmDuplicate( void );
extern HB_EXPORT void   hb_xvmDuplUnRef( void );
extern HB_EXPORT void   hb_xvmDuplTwo( void );
extern HB_EXPORT void   hb_xvmPushUnRef( void );
extern HB_EXPORT void   hb_xvmSwap( int iCount );
extern HB_EXPORT BOOL   hb_xvmForTest( void );
extern HB_EXPORT void   hb_xvmFuncPtr( void );
extern HB_EXPORT BOOL   hb_xvmEqual( void );                      /* checks if the two latest values on the stack are equal, removes both and leaves result */
extern HB_EXPORT BOOL   hb_xvmExactlyEqual( void );               /* checks if the two latest values on the stack are exactly equal, removes both and leaves result */
extern HB_EXPORT BOOL   hb_xvmNotEqual( void );                   /* checks if the two latest values on the stack are not equal, removes both and leaves result */
extern HB_EXPORT BOOL   hb_xvmLess( void );                       /* checks if the latest - 1 value is less than the latest, removes both and leaves result */
extern HB_EXPORT BOOL   hb_xvmLessEqual( void );                  /* checks if the latest - 1 value is less than or equal the latest, removes both and leaves result */
extern HB_EXPORT BOOL   hb_xvmGreater( void );                    /* checks if the latest - 1 value is greater than the latest, removes both and leaves result */
extern HB_EXPORT BOOL   hb_xvmGreaterEqual( void );               /* checks if the latest - 1 value is greater than or equal the latest, removes both and leaves result */
extern HB_EXPORT BOOL   hb_xvmInstring( void );                   /* check whether string 1 is contained in string 2 */
extern HB_EXPORT BOOL   hb_xvmPlus( void );                       /* sums the latest two values on the stack, removes them and leaves the result */
extern HB_EXPORT BOOL   hb_xvmPlusEq( void );
extern HB_EXPORT BOOL   hb_xvmPlusEqPop( void );
extern HB_EXPORT BOOL   hb_xvmMinus( void );                      /* substracts the latest two values on the stack, removes them and leaves the result */
extern HB_EXPORT BOOL   hb_xvmMinusEq( void );
extern HB_EXPORT BOOL   hb_xvmMinusEqPop( void );
extern HB_EXPORT BOOL   hb_xvmMult( void );                       /* multiplies the latest two values on the stack, removes them and leaves the result */
extern HB_EXPORT BOOL   hb_xvmMultEq( void );
extern HB_EXPORT BOOL   hb_xvmMultEqPop( void );
extern HB_EXPORT BOOL   hb_xvmDivide( void );                     /* divides the latest two values on the stack, removes them and leaves the result */
extern HB_EXPORT BOOL   hb_xvmDivEq( void );
extern HB_EXPORT BOOL   hb_xvmDivEqPop( void );
extern HB_EXPORT BOOL   hb_xvmModulus( void );                    /* calculates the modulus of latest two values on the stack, removes them and leaves the result */
extern HB_EXPORT BOOL   hb_xvmModEq( void );
extern HB_EXPORT BOOL   hb_xvmModEqPop( void );
extern HB_EXPORT BOOL   hb_xvmPower( void );
extern HB_EXPORT BOOL   hb_xvmExpEq( void );
extern HB_EXPORT BOOL   hb_xvmExpEqPop( void );
extern HB_EXPORT BOOL   hb_xvmInc( void );
extern HB_EXPORT BOOL   hb_xvmIncEq( void );
extern HB_EXPORT BOOL   hb_xvmIncEqPop( void );
extern HB_EXPORT BOOL   hb_xvmDec( void );
extern HB_EXPORT BOOL   hb_xvmDecEq( void );
extern HB_EXPORT BOOL   hb_xvmDecEqPop( void );

extern HB_EXPORT void   hb_xvmArrayDim( USHORT uiDimensions );    /* generates an uiDimensions Array and initialize those dimensions from the stack values */
extern HB_EXPORT void   hb_xvmArrayGen( ULONG ulElements );       /* generates an ulElements Array and fills it from the stack values */
extern HB_EXPORT BOOL   hb_xvmArrayPush( void );                  /* pushes an array element to the stack, removing the array and the index from the stack */
extern HB_EXPORT BOOL   hb_xvmArrayPushRef( void );               /* pushes a reference to an array element to the stack, removing the array and the index from the stack */
extern HB_EXPORT BOOL   hb_xvmArrayPop( void );                   /* pops a value from the stack */
extern HB_EXPORT void   hb_xvmHashGen( ULONG ulElements );        /* generates an ulElements Hash and fills it from the stack values */

extern HB_EXPORT void   hb_xvmLocalName( USHORT uiLocal, char * szLocalName );
extern HB_EXPORT void   hb_xvmStaticName( BYTE bIsGlobal, USHORT uiStatic, char * szStaticName );
extern HB_EXPORT void   hb_xvmModuleName( char * szModuleName );

extern HB_EXPORT BOOL   hb_xvmMacroDo( USHORT uiArgSets );
extern HB_EXPORT BOOL   hb_xvmMacroFunc( USHORT uiArgSets );
extern HB_EXPORT BOOL   hb_xvmMacroSend( USHORT uiArgSets );
extern HB_EXPORT BOOL   hb_xvmMacroArrayGen( USHORT uiArgSets );
extern HB_EXPORT BOOL   hb_xvmMacroPush( BYTE bFlags );
extern HB_EXPORT BOOL   hb_xvmMacroPushRef( void );
extern HB_EXPORT BOOL   hb_xvmMacroPushIndex( void );
extern HB_EXPORT BOOL   hb_xvmMacroPushArg( PHB_SYMB pSymbol, BYTE bFlags );
extern HB_EXPORT BOOL   hb_xvmMacroPushList( BYTE bFlags );
extern HB_EXPORT BOOL   hb_xvmMacroPushAliased( BYTE bFlags );
extern HB_EXPORT BOOL   hb_xvmMacroPushPare( BYTE bFlags );
extern HB_EXPORT BOOL   hb_xvmMacroPop( BYTE bFlags );
extern HB_EXPORT BOOL   hb_xvmMacroPopAliased( BYTE bFlags );
extern HB_EXPORT BOOL   hb_xvmMacroSymbol( void );
extern HB_EXPORT BOOL   hb_xvmMacroText( void );

extern HB_EXPORT void   hb_xvmPushStringHidden( char * szText, ULONG length );
extern HB_EXPORT void   hb_xvmPushDouble( double dNumber, int iWidth, int iDec );
#ifdef HB_LONG_LONG_OFF
extern HB_EXPORT void   hb_xvmPushLongLong( double dNumber );
#else
extern HB_EXPORT void   hb_xvmPushLongLong( LONGLONG llNumber );
#endif

#define hb_xvmPushLogical( f )            hb_vmPushLogical( f )
#define hb_xvmPushInteger( i )            hb_vmPushInteger( i )
#define hb_xvmPushLong( l )               hb_vmPushLong( l )
#define hb_xvmPushNil()                   hb_vmPushNil()
#define hb_xvmPushStringConst( psz, ul )  hb_vmPushStringPcode( psz, ul )
#define hb_xvmPushSymbol( p )             hb_vmPushSymbol( p )
#define hb_xvmPushDate( p )               hb_vmPushDate( p )


/*
 * additional multi PCODE operations
 */
extern HB_EXPORT BOOL hb_xvmArrayItemPush( ULONG ulIndex );
extern HB_EXPORT BOOL hb_xvmArrayItemPop( ULONG ulIndex );
extern HB_EXPORT BOOL hb_xvmMultByInt( LONG lValue );
extern HB_EXPORT BOOL hb_xvmDivideByInt( LONG lValue );
extern HB_EXPORT BOOL hb_xvmAddInt( LONG lValue );
extern HB_EXPORT void hb_xvmLocalSetInt( int iLocal, LONG lValue );
/*extern HB_EXPORT void hb_xvmLocalSetStr( int iLocal, const char * pValue, ULONG ulLen );*/
extern HB_EXPORT void hb_xvmPushFuncSymbol( PHB_SYMB pSym );

extern HB_EXPORT BOOL hb_xvmLessThenInt( LONG lValue );
extern HB_EXPORT BOOL hb_xvmLessThenIntIs( LONG lValue, BOOL *fValue );
extern HB_EXPORT BOOL hb_xvmLessEqualThenInt( LONG lValue );
extern HB_EXPORT BOOL hb_xvmLessEqualThenIntIs( LONG lValue, BOOL *fValue );
extern HB_EXPORT BOOL hb_xvmGreaterThenInt( LONG lValue );
extern HB_EXPORT BOOL hb_xvmGreaterThenIntIs( LONG lValue, BOOL *fValue );
extern HB_EXPORT BOOL hb_xvmGreaterEqualThenInt( LONG lValue );
extern HB_EXPORT BOOL hb_xvmGreaterEqualThenIntIs( LONG lValue, BOOL *fValue );
extern HB_EXPORT BOOL hb_xvmEqualInt( LONG lValue );
extern HB_EXPORT BOOL hb_xvmEqualIntIs( LONG lValue, BOOL *fValue );
extern HB_EXPORT BOOL hb_xvmNotEqualInt( LONG lValue );
extern HB_EXPORT BOOL hb_xvmNotEqualIntIs( LONG lValue, BOOL *fValue );

extern HB_EXPORT BOOL hb_xvmLocalAdd( int iLocal );
extern HB_EXPORT BOOL hb_xvmStaticAdd( USHORT uiStatic );
extern HB_EXPORT BOOL hb_xvmMemvarAdd( PHB_SYMB pSymbol );

extern HB_EXPORT void hb_xvmCopyLocals( int iDest, int iSource );

HB_EXTERN_END

#endif /* HB_XVM_H_ */
