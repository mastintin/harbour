#include "pcode.h"
#include <stdio.h>

/* #if DOS32 */
static BYTE prgFunction[] = { 0x68, 0x00, 0x00, 0x00, 0x00,
                              0x68, 0x00, 0x00, 0x00, 0x00,
                              0xE8, 0x00, 0x00, 0x00, 0x00,
                              0x83, 0xC4, 0x08,
                              0xC3 };
     /* push offset pcode
        push offset symbols
        call near relative VirtualMachine
        add esp, 8
        ret near                   */

     /* This is the assembler output from : VirtualMachine(pcode,symbols). */

/* #elseif DOS16 */
/* #elseif MAC */
/* #elseif ... */
/* #endif */

typedef union
{
   PBYTE       pAsmData;       /* The assembler bytes            */
   HARBOURFUNC pFunPtr;        /* The (dynamic) harbour function */
} ASM_CALL, *PASM_CALL;

typedef struct
{
   char      *szName;          /* Name of the function         */
   PASM_CALL  pAsmCall;        /* Assembler call               */
   PBYTE      pCode;           /* P-code                       */
} DYNFUNC, *PDYNFUNC;

#define SYM_NOLINK  0              /* Symbol does not have to be linked */
#define SYM_FUNC    1              /* Defined function                  */
#define SYM_EXTERN  2              /* Previously defined function       */

PASM_CALL CreateFun( PSYMBOL, PBYTE );   /* Create a dynamic function*/

HARBOUR Runner();

#include "run_exp.h"
/*
 *
 * This file contains the exportable functions available to the Harbour program
 *
 * Currently being discussed in 'Static initializers'
 *
 * If the discussion has finished, it can be removed from here.
 *
 */

/* Same story.

   All the function pointers of the internal functions
   Including Runner itself, since the first symbol gets executed by Harbour ;-)
*/
#include <init.h>

/*
   Runner

   This program will get the data from the .HRB file and run the p-code
   contained in it.

   In due time it should also be able to collect the data from the
   binary/executable itself
*/
HARBOUR Runner( void )
{
   char  cLong[4];                              /* Temporary long           */
   char *szFileName;
   char *szTemp;                                /* Temporary buffer         */
   char *szIdx;

   FILE *file;

   ULONG ulSymbols;                             /* Number of symbols        */
   ULONG ulFuncs;                               /* Number of functions      */
   ULONG ulSize;                                /* Size of function         */
   ULONG ul, ul2;

   BYTE  bCont;

   PSYMBOL  pSymRead = NULL;                    /* Symbols read             */
   PDYNFUNC pPCode   = NULL;                    /* Functions read           */
   PDYNSYM  pDynSym;

   if( _pcount() == 0 )
      printf( "\nPlease give HRB file name\n" );
   else
   {
      szFileName = _parc( 1 );
      file = fopen( szFileName, "rb" );         /* Open as binary           */
      if( file )
      {
         fread( &cLong, 4, 1, file );           /* Read number of symbols   */
         ulSymbols = ( (BYTE) cLong[0] )           +
                     ( (BYTE) cLong[1] ) * 0x100   +
                     ( (BYTE) cLong[2] ) * 0x10000 +
                     ( (BYTE) cLong[3] ) * 0x1000000;
         printf("\nNumber of symbols=%li\n", ulSymbols );

         pSymRead = _xgrab( ulSymbols * sizeof( SYMBOL ) );

         szTemp   = _xgrab( 256 );              /* Must be enough for now   */

         for( ul=0; ul < ulSymbols; ul++)       /* Read symbols in .HRB     */
         {
            szIdx = szTemp;
            bCont = TRUE;
            do
            {
               fread( szIdx, 1, 1, file );
               if( *szIdx )
                  szIdx++;
               else
                  bCont = FALSE;
            } while( bCont );

            pSymRead[ ul ].szName = (char *) _xgrab( szIdx - szTemp + 1 );
            strcpy( pSymRead[ ul ].szName, szTemp );
            printf("\nName = %s.", pSymRead[ ul].szName );

            fread( szTemp, 2, 1, file );

            pSymRead[ ul ].cScope  = szTemp[ 0 ];
            pSymRead[ ul ].pFunPtr = (void *) szTemp[ 1 ];
            pSymRead[ ul ].pDynSym = NULL;
         }

         fread( &cLong, 4, 1, file );           /* Read number of functions */
         ulFuncs = ( (BYTE) cLong[0] )           +
                   ( (BYTE) cLong[1] ) * 0x100   +
                   ( (BYTE) cLong[2] ) * 0x10000 +
                   ( (BYTE) cLong[3] ) * 0x1000000;
         printf("\nNumber of functions=%li\n", ulFuncs );

         pPCode = ( PDYNFUNC ) _xgrab( ulFuncs * sizeof( DYNFUNC ) );
         for( ul=0; ul < ulFuncs; ul++)        /* Read symbols in .HRB     */
         {
            szIdx = szTemp;
            bCont = TRUE;
            do
            {
               fread( szIdx, 1, 1, file );
               if( *szIdx )
                  szIdx++;
               else
                  bCont = FALSE;
            } while( bCont );
            printf("\nName = %s.", szTemp );
            pPCode[ ul ].szName = (char *) _xgrab( szIdx - szTemp + 1);
            strcpy( pPCode[ ul ].szName, szTemp );

            fread( &cLong, 4, 1, file );        /* Read size of function    */
            ulSize = ( (BYTE) cLong[0] )             +
                     ( (BYTE) cLong[1] ) * 0x100     +
                     ( (BYTE) cLong[2] ) * 0x10000   +
                     ( (BYTE) cLong[3] ) * 0x1000000 + 1;
            printf("\nSize of function=%li\n", ulSize );
            pPCode[ ul ].pCode = _xgrab( ulSize );
            fread( pPCode[ ul ].pCode, 1, ulSize, file );
                                                /* Read the block           */

            pPCode[ ul ].pAsmCall = CreateFun( pSymRead, pPCode[ ul ].pCode );
                                                /* Create matching dynamic  */
                                                /* function                 */
         }

         ul2 = 0;
         for( ul = 0; ul < ulSymbols; ul++ )    /* Quick & Dirty linking    */
         {

            if( ( (ULONG) pSymRead[ ul ].pFunPtr ) == SYM_FUNC )
            {                                   /* Internal function        */
               pSymRead[ ul ].pFunPtr = pPCode[ ul2++ ].pAsmCall->pFunPtr;
            }
            else if( ( (ULONG) pSymRead[ ul ].pFunPtr ) == SYM_EXTERN )
            {                                   /* External function        */
               pDynSym = FindDynSym( pSymRead[ ul ].szName );
               if( !pDynSym )
               {
                  printf( "\nCould you please add : %s to run_exp.h and compile me\nThank you.",
                          pSymRead[ ul ].szName );
                  exit( 1 );
               }
               pSymRead[ ul ].pFunPtr = pDynSym->pFunPtr;
            }
         }

         pSymRead[ 0 ].pFunPtr();               /* Run the thing !!!        */

         for( ul = 0; ul < ulFuncs; ul++ )
         {
            _xfree( pPCode[ ul ].pAsmCall->pAsmData );
            _xfree( pPCode[ ul ].pAsmCall           );
            _xfree( pPCode[ ul ].pCode              );
            _xfree( pPCode[ ul ].szName             );
         }

         for( ul = 0; ul < ulSymbols; ul++ )
         {
            _xfree( pSymRead[ ul ].szName );
         }

         _xfree( pPCode );
         _xfree( szTemp );
         _xfree( pSymRead );
         fclose( file );
      }
      else
      {
         printf( "\nCannot open %s\n", szFileName );
      }
   }
}

/* Patch an address of the dynamic function */
void Patch( PBYTE pCode, ULONG ulOffset, void *Address )
{
/* #if 32 bits and low byte first */

   pCode[ ulOffset     ] = ( (ULONG) Address       ) & 0xFF;
   pCode[ ulOffset + 1 ] = ( (ULONG) Address >>  8 ) & 0xFF;
   pCode[ ulOffset + 2 ] = ( (ULONG) Address >> 16 ) & 0xFF;
   pCode[ ulOffset + 3 ] = ( (ULONG) Address >> 24 ) & 0xFF;

/* #elseif 16 bits and low byte first */
/* #elseif 32 bits and high byte first */
/* #elseif ... */
/* #endif */
}

/* Intel specific ?? Patch an address relative to the next instruction */
void PatchRelative( PBYTE pCode, ULONG ulOffset, void *Address, ULONG ulNext )
{
/* #if 32 bits and low byte first */
   ULONG ulBase = (ULONG) pCode + ulNext;
                                /* Relative to next instruction */
   ULONG ulRelative = (ULONG) Address - ulBase;

   pCode[ ulOffset     ] = ( ulRelative       ) & 0xFF;
   pCode[ ulOffset + 1 ] = ( ulRelative >>  8 ) & 0xFF;
   pCode[ ulOffset + 2 ] = ( ulRelative >> 16 ) & 0xFF;
   pCode[ ulOffset + 3 ] = ( ulRelative >> 24 ) & 0xFF;

/* #elseif 16 bits and low byte first */
/* #elseif 32 bits and high byte first */
/* #elseif ... */
/* #endif */
}

/*
   Create dynamic function.

   This function is needed, since it will allow the existing strategy of
   function pointers to work properly.

   For each Harbour function a little program calling the virtual machine
   should be present (see : *.c)

   Since these programs no longer exists when using this system, they should
   be create dynamically at run-time.

   If a .PRG contains 10 functions, 10 dynamic functions are created which
   are all the same :-) except for 1 pointer.
*/
PASM_CALL CreateFun( PSYMBOL pSymbols, PBYTE pCode )
{
   PASM_CALL asmRet = (PASM_CALL) _xgrab( sizeof( ASM_CALL ) );

   asmRet->pAsmData = (PBYTE) _xgrab( sizeof( prgFunction ) );
   memcpy( asmRet->pAsmData, prgFunction, sizeof( prgFunction ) );
                                              /* Copy new assembler code in */
/* #if DOS32 */

   Patch( asmRet->pAsmData,  1, pSymbols );   /* Insert pointer to testsym  */
   Patch( asmRet->pAsmData,  6, pCode);       /* Insert pointer to testcode */
   PatchRelative( asmRet->pAsmData, 11, &VirtualMachine, 15 );
                                      /* Insert pointer to VirtualMachine() */

/* #elseif DOS16 */
/* #elseif MAC */
/* #elseif ... */
/* #endif */
   return( asmRet );
}

