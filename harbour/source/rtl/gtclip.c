/*
 * $Id$
 */

/*
 * Harbour Project source code:
 *    Low level ClipBoard code common to some GT drivers
 *
 * Copyright 2006 Przemyslaw Czerpak <druzus / at / priv.onet.pl>
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


/* NOTE: User programs should never call this layer directly! */

#define HB_OS_WIN_32_USED
#include "hbgtcore.h"

#if defined( HB_OS_WIN_32 )

void hb_gt_w32_SetClipboard( UINT uFormat, char * szClipData, ULONG ulLen )
{
   LPTSTR  lptstrCopy;
   HGLOBAL hglbCopy;

   if( OpenClipboard( NULL ) )
   {
      EmptyClipboard();

      /* Allocate a global memory object for the text. */
      hglbCopy = GlobalAlloc( GMEM_MOVEABLE, ulLen + 1 );
      if( hglbCopy )
      {
         /* Lock the handle and copy the text to the buffer. */
         lptstrCopy = ( LPSTR ) GlobalLock( hglbCopy );
         memcpy( lptstrCopy, szClipData, ulLen );
         lptstrCopy[ ulLen ] = 0;
         GlobalUnlock( hglbCopy );
         /* Place the handle on the clipboard. */
         SetClipboardData( uFormat, hglbCopy );
      }
      CloseClipboard();
   }
}

BOOL hb_gt_w32_GetClipboard( UINT uFormat, char ** pszClipData, ULONG *pulLen )
{
   HGLOBAL hglb;
   LPTSTR  lptstr;

   *pulLen = 0;
   *pszClipData = NULL;
   if( IsClipboardFormatAvailable( uFormat ) && OpenClipboard( NULL ) )
   {
      hglb = GetClipboardData( uFormat );
      if( hglb )
      {
         lptstr = ( LPSTR ) GlobalLock( hglb );
         if( lptstr != NULL )
         {
            *pulLen = GlobalSize( hglb );

            if( *pulLen )
            {
               *pszClipData = ( char * ) hb_xgrab( *pulLen + 1 );
               memcpy( *pszClipData, lptstr, *pulLen + 1 );
            }
            GlobalUnlock( hglb );
         }
      }
      CloseClipboard();
   }

   return *pulLen != 0;
}

#endif /* HB_OS_WIN_32 */