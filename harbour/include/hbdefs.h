/*
 * $Id$
 */

/*
 * Harbour Project source code:
 * Header file for compiler and runtime basic type declarations
 *
 * Copyright 1999 {list of individual authors and e-mail addresses}
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

#ifndef HB_DEFS_H_
#define HB_DEFS_H_

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "hbsetup.h"

#if defined(__IBMCPP__)
   /* With the exception of WORD, the IBM Visual Age C++ compiler has
      its own definitions of the Harbour types defined in the #else
      section of this #ifdef block, most of which conflict with the
      Harbour #undefs, due to typedef being the prevalent method of
      defining the types in IBMCPP, whereas Harbour assumes that the
      definitions that it is replacing have been defined using
      #define. Therefore, it is necessary to skip the Harbour
      definition section when using the IBMCPP compiiler, include
      the IBMCPP type definitions, and then add the definition for WORD

      NOTE: This only applies to the common types that most C compilers
            define. Any new types, particulary those that start with
            HB_, must be placed AFTER the #endif __IBMCPP__ line!
   */
   #define INCL_TYPES
   #include <os2.h>
   typedef unsigned short int WORD;
   #undef INT
   #undef UINT

#else

#if ! defined(HB_DONT_DEFINE_BASIC_TYPES)

#undef BOOL                            /* boolean */
typedef int BOOL;

#undef BYTE
typedef unsigned char BYTE;            /* 1 byte unsigned */

#undef SHORT                           /* 2 bytes signed */
typedef short int SHORT;

#undef WORD                            /* 2 bytes unsigned */
typedef unsigned short int WORD;

#undef USHORT                          /* 2 bytes unsigned */
typedef unsigned short int USHORT;

#undef LONG                            /* 4 bytes signed */
typedef long LONG;

#undef ULONG                           /* 4 bytes unsigned */
typedef unsigned long ULONG;

#undef DWORD                           /* 4 bytes unsigned */
typedef unsigned long DWORD;

#undef FALSE
#undef TRUE
#define FALSE  0
#define TRUE   1

#endif /* HB_DONT_DEFINE_BASIC_TYPES */
#endif /* __IBMCPP__ */

#ifndef MAX
#define MAX( a, b )             ( ( ( a ) > ( b ) ) ? ( a ) : ( b ) )
#endif
#ifndef MIN
#define MIN( a, b )             ( ( ( a ) < ( b ) ) ? ( a ) : ( b ) )
#endif

#ifndef LOBYTE
#define LOBYTE( w )             ( ( BYTE )( w ) )
#endif
#ifndef HIBYTE
#define HIBYTE( w )             ( ( BYTE )( ( ( WORD )( w ) >> 8 ) & 0xFF ) )
#endif
#ifndef LOWORD
#define LOWORD( l )             ( ( WORD )( l ) )
#endif
#ifndef MKINT
#define MKINT( b1, b2 )         ( ( ( long ) b2 ) <<  8 ) | b1
#endif
#ifndef MKLONG
#define MKLONG( b1, b2, b3, b4 ) ( ( ( long ) b4 ) << 24 ) | \
                                 ( ( ( long ) b3 ) << 16 ) | \
                                 ( ( ( long ) b2 ) <<  8 ) | b1
#endif

#define HB_SYMBOL_UNUSED( symbol ) ( void ) symbol

#ifdef __GNUC__
   #define pascal __attribute__ ((stdcall))
#endif

#ifdef _MSC_VER
   #define HARBOUR void
   #define EXTERNAL_LINKAGE
#else
   #ifdef __IBMCPP__
      #define HARBOUR void
      #define EXTERNAL_LINKAGE _LNK_CONV
   #else
      #define HARBOUR void pascal
      #define EXTERNAL_LINKAGE
   #endif
#endif

#define __HARBOUR__

typedef HARBOUR ( * PHB_FUNC )( void );
typedef PHB_FUNC HB_FUNC_PTR;

typedef LONG HB_HANDLE;     /* handle to memvar value */
typedef char SYMBOLSCOPE;   /* stores symbol's scope */

#endif /* HB_DEFS_H_ */
