/*
 * $Id$

   Copyright(C) 1999 by Bruno Cantero.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published
   by the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR
   PURPOSE.  See the GNU General Public License for more details.

   You should have received a copy of the GNU General Public
   License along with this program; if not, write to:

   The Free Software Foundation, Inc.,
   675 Mass Ave, Cambridge, MA 02139, USA.

   You can contact me at: bruno@issnet.net
 */

#include "extend.h"
#include "init.h"
#include "rddapi.h"
#include "rddsys.ch"

HARBOUR HB__SDF( void );
HARBOUR HB_SDF_GETFUNCTABLE( void );

HB_INIT_SYMBOLS_BEGIN( sdf1__InitSymbols )
{ "_SDF",             FS_PUBLIC, HB__SDF,             0 },
{ "SDF_GETFUNCTABLE", FS_PUBLIC, HB_SDF_GETFUNCTABLE, 0 }
HB_INIT_SYMBOLS_END( sdf1__InitSymbols )
#if ! defined(__GNUC__)
#pragma startup sdf1__InitSymbols
#endif

static ERRCODE Info( AREAP pArea, USHORT uiIndex, PHB_ITEM pItem )
{
   printf( "Calling SDF: Info()\n" );
   return SUCCESS;
}

static ERRCODE ReadDBHeader( AREAP pArea )
{
   printf( "Calling SDF: ReadDBHeader()\n" );
   return SUCCESS;
}

static ERRCODE WriteDBHeader( AREAP pArea )
{
   printf( "Calling SDF: WriteDBHeader()\n" );
   return SUCCESS;
}

static RDDFUNCS sdfSuper = { 0 };

static RDDFUNCS sdfTable = { 0,                 /* Super Bof */
                             0,                 /* Super Eof */
                             0,                 /* Super Found */
                             0,                 /* Super GoBottom */
                             0,                 /* Super GoTo */
                             0,                 /* Super GoToId */
                             0,                 /* Super GoTop */
                             0,                 /* Super Skip */
                             0,                 /* Super AddField */
                             0,                 /* Super CreateFields */
                             0,                 /* Super FieldCount */
                             0,                 /* Super FieldName */
                             0,                 /* Super GetValue */
                             0,                 /* Super RecCount */
                             0,                 /* Super RecNo */
                             0,                 /* Super SetFieldExtent */
                             0,                 /* Super Close */
                             0,                 /* Super Create */
                             Info,
                             0,                 /* Super NewArea */
                             0,                 /* Super Open */
                             0,                 /* Super Release */
                             0,                 /* Super StructSize */
                             0,                 /* Super SysName */
                             ReadDBHeader,
                             WriteDBHeader
                           };

HARBOUR HB__SDF( void )
{
}

HARBOUR HB_SDF_GETFUNCTABLE( void )
{
   RDDFUNCS * pTable;
   USHORT * uiCount;

   uiCount = ( USHORT * ) hb_parnl( 1 );
   * uiCount = RDDFUNCSCOUNT;
   pTable = ( RDDFUNCS * ) hb_parnl( 2 );
   if( pTable )
      hb_retni( hb_rddInherit( pTable, &sdfTable, &sdfSuper, 0 ) );
   else
      hb_retni( FAILURE );
}
