/*
 * $Id$
 */

/*
 * Harbour Project source code:
 * TBrowse Class
 *
 * Copyright 1999 Antonio Linares <alinares@fivetech.com>
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

/* NOTE: Don't use SAY in this module, use DispOut(), DispOutAt() instead,
         otherwise it will not be CA-Cl*pper compatible. [vszakats] */

/* TODO: :firstScrCol() --> nScreenCol
         Determines screen column where the first table column is displayed.
         Xbase++ compatible method */

/* TODO: :viewArea() --> aViewArea
         Determines the coordinates for the data area of a TBrowse object.
         Xbase++ compatible method */

/* TOFIX: Clipper will determine the column width when the TBROWSE is displayed
          at the first time. (while Harbour does that when adding the column)
          Clipper will leave NIL in the :width variable until determined. Also
          Clipper will not allow the user to assign a NIL to the :width
          variable. Clipper will determine the width even when the caller
          explicitly set the :width after adding the column. [vszakats] */

/* TOFIX: Multiline headers and footer are not supported. [vszakats] */

/* TOFIX: The cursor is not left at the same position as in Clipper, this is
          very important, since several apps relies on it. Check CA-Cl*pper
          5.2e for the right implementation since 5.3 broke it. [vszakats] */

/* TOFIX: Clipper will refresh the current row even when a Down() is issued in
          the last row, or an Up() in the first one, this is important for
          cursor positioning. Yes, Harbour is smarter, but it's not compatible.
          [vszakats] */

#include "common.ch"
#include "hbclass.ch"
#include "color.ch"
#include "inkey.ch"
CLASS TBrowse

   DATA aColumns      // Array to hold all browse columns
   DATA autoLite      // Logical value to control highlighting
   DATA cargo         // User-definable variable
   DATA colorSpec     // Color table for the TBrowse display
   DATA colPos        // Current cursor column position
   DATA colSep        // Column separator character
   DATA footSep       // Footing separator character
   DATA freeze        // Number of columns to freeze
   DATA goBottomBlock // Code block executed by TBrowse:goBottom()
   DATA goTopBlock    // Code block executed by TBrowse:goTop()
   DATA headSep       // Heading separator character
   DATA hitBottom     // Indicates the end of available data
   DATA hitTop        // Indicates the beginning of available data
   DATA leftVisible   // Indicates position of leftmost unfrozen column in display
   DATA nBottom       // Bottom row number for the TBrowse display
   DATA nLeft         // Leftmost column for the TBrowse display
   DATA nRight        // Rightmost column for the TBrowse display
   DATA nTop          // Top row number for the TBrowse display
   DATA rightVisible  // Indicates position of rightmost unfrozen column in display
   DATA rowCount      // Number of visible data rows in the TBrowse display
   DATA rowPos        // Current cursor row position
   DATA skipBlock     // Code block used to reposition data source
   DATA stable        // Indicates if the TBrowse object is stable

   DATA aRedraw       // Array of logical items indicating, is appropriate row need to be redraw
   DATA RelativePos   // Indicates record position relatively position of first record on the screen
   DATA lHeaders      // Internal variable which indicates whether there are column footers to paint
   DATA lFooters      // Internal variable which indicates whether there are column footers to paint
   DATA aRect         // The rectangle specified with ColorRect()
   DATA aRectColor    // The color positions to use in the rectangle specified with ColorRect()
   #ifdef HB_COMPAT_C53
   DATA aKeys
   #endif
   METHOD New(nTop, nLeft, nBottom, nRight)  // Constructor
   METHOD Down()      // Moves the cursor down one row
   METHOD End()       // Moves the cursor to the rightmost visible data column
   METHOD GoBottom()  // Repositions the data source to the bottom of file
   METHOD GoTop()     // Repositions the data source to the top of file
   METHOD Home()      // Moves the cursor to the leftmost visible data column
   MESSAGE Left() METHOD _Left() // Moves the cursor left one column
   METHOD PageDown()  // Repositions the data source downward
   METHOD PageUp()    // Repositions the data source upward
   METHOD PanEnd()    // Moves the cursor to the rightmost data column
   METHOD PanHome()   // Moves the cursor to the leftmost visible data column
   METHOD PanLeft()   // Pans left without changing the cursor position
   METHOD PanRight()  // Pans right without changing the cursor position
   MESSAGE Right() METHOD _Right() // Moves the cursor right one column
   METHOD Up()        // Moves the cursor up one row

   METHOD AddColumn( oCol )
   METHOD ColCount() INLINE Len( ::aColumns )
   METHOD ColorRect()              // Alters the color of a rectangular group of cells
                                   // Returns the display width of a particular column
   METHOD ColWidth( nColumn ) INLINE iif( 0 < nColumn .and. nColumn <= Len( ::aColumns ),;
                                          ::aColumns[ nColumn ]:Width, NIL )
   METHOD Configure( nMode )       // Reconfigures the internal settings of the TBrowse object
                                   // nMode is an undocumented parameter in CA-Cl*pper
   METHOD LeftDetermine()          // Determine leftmost unfrozen column in display
   METHOD DeHilite()               // Dehighlights the current cell

   METHOD DelColumn( nPos )        // Delete a column object from a browse

   METHOD ForceStable()            // Performs a full stabilization

   METHOD GetColumn( nColumn ) INLINE iif( 0 < nColumn .and. nColumn <= Len( ::aColumns ),;
                                          ::aColumns[ nColumn ], NIL ) // Gets a specific TBColumn object

   METHOD Hilite()                 // Highlights the current cell

   METHOD InsColumn( nPos, oCol ) INLINE ASize( ::aColumns, Len( ::aColumns + 1 ) ),;
                                  AIns( ::aColumns, nPos ),;
                                  ::aColumns[ nPos ] := oCol, ::Configure( 2 ), oCol
                                   // Insert a column object in a browse

   METHOD Invalidate()             // Forces entire redraw during next stabilization
   METHOD RefreshAll()     INLINE ::Invalidate() // Causes all data to be recalculated during the next stabilize
   METHOD RefreshCurrent() INLINE ::aRedraw[ ::RowPos ] := .f., ::Stable := .f., Self // Causes the current row to be refilled and repainted on next stabilize

   METHOD SetColumn( nColumn, oCol ) INLINE iif( 0 < nColumn .and. nColumn <= Len( ::aColumns ),;
                                                ::aColumns[ nColumn ] := oCol, NIL ), oCol // Replaces one TBColumn object with another

   METHOD Stabilize()              // Performs incremental stabilization

   METHOD DispCell( nColumn, cColor ) // Displays a single cell
   #ifdef HB_COMPAT_C53
   method SetKey(nKey,bBlock)
   method applykey(nKey)
   method initKeys(Self)
   method tapplykey(nKey,o)
   #endif
ENDCLASS

METHOD New(nTop, nLeft, nBottom, nRight) CLASS TBrowse

   default  nTop    to 0
   default  nLeft   to 0
   default  nBottom to MaxRow()
   default  nRight  to MaxCol()

   ::aColumns    := {}
   ::AutoLite    := .T.
   ::leftVisible := 1
   ::ColPos      := 1
   ::Freeze      := 0
   ::HitBottom   := .F.
   ::HitTop      := .F.
   ::ColorSpec   := SetColor()
   ::ColSep      := " "
   ::FootSep     := ""
   ::HeadSep     := ""
   ::RowPos      := 1
   ::stable      := .F.
   ::RelativePos := 1
   ::aRedraw     := {}
   ::lHeaders    := .F.
   ::lFooters    := .F.
   ::aRect       := {}
   ::aRectColor  := {}

   ::nTop := nTop
   ::nLeft := nLeft
   ::nBottom := nBottom
   ::nRight := nRight

return Self


METHOD Configure(nMode) CLASS TBrowse

   local n

   ::lHeaders := .F.
   ::lFooters := .F.

   // Are there any column header to paint ?
   for n := 1 to Len(::aColumns)
      if !Empty(::aColumns[n]:Heading)
         ::lHeaders := .T.
         exit
      endif
   next

   // Are there any column footer to paint ?
   for n := 1 to Len(::aColumns)
      if !Empty(::aColumns[n]:Footing)
         ::lFooters := .T.
         exit
      endif
   next

   ::Invalidate()

return Self

// Adds a TBColumn object to the TBrowse object
METHOD AddColumn( oCol ) CLASS TBrowse

   local nWidthMax := ::nRight - ::nLeft + 1  // Visible width of the browse

   if oCol:Width > nWidthMax
      // with values lower than -4 it SIGSEVs here and there :-(
      oCol:Width := nWidthMax - 4
   endif

   AAdd( ::aColumns, oCol )
   ::Configure( 2 )

return Self


METHOD DelColumn( nPos ) CLASS TBrowse

   local oCol := ::aColumns[ nPos ]
   local n

   ADel( ::aColumns, nPos )
   ASize( ::aColumns, Len( ::aColumns ) - 1 )

   ::Configure( 2 )

return oCol


METHOD Down() CLASS TBrowse

   local n

   ::HitTop := .F.
   if !::HitBottom
      ::DeHilite()
      if Eval( ::SkipBlock, 1 ) != 0
         if ::RowPos < ::RowCount
            ::RowPos++
            ::Hilite()
            ::RelativePos++
         else
            n := ::nTop + iif( ::lHeaders, 1, 0 ) + iif( Empty( ::HeadSep ), 0, 1 )
            Scroll( n, ::nLeft, n + ::RowCount - 1, ::nRight, 1 )
            ::RefreshCurrent()
         endif
      else
         ::Hilite()
         ::HitBottom := .t.
      endif
   endif

return Self

METHOD End() CLASS TBrowse

   if ::ColPos < ::rightVisible
      ::ColPos := ::rightVisible
      ::RefreshCurrent()
   endif

return Self

METHOD GoBottom() CLASS TBrowse

   local nToEnd := 0

   ::HitTop := .F.
   ::HitBottom := .F.

   // if there are fewer records than available display area
   if (nToEnd := Eval(::SkipBlock, ::RowCount)) < ::RowCount
      ::RefreshAll()
      ::RowPos += nToEnd
      ::RelativePos += nToEnd
   else
      if Eval( ::goBottomBlock ) != 0
         ::RefreshAll()
         ::RowPos := ::RowCount
         ::RelativePos := ::RowCount
      endif
   endif

return Self

METHOD GoTop() CLASS TBrowse

   ::HitTop := .F.
   ::HitBottom := .F.
   if Eval( ::goTopBlock ) != 0
      ::RefreshAll()
      ::RowPos := 1
      ::RelativePos := 1
   endif

return Self

METHOD Home() CLASS TBrowse

   if ::ColPos != ::leftVisible
      ::ColPos := ::leftVisible
      ::RefreshCurrent()
   endif

return Self

METHOD Invalidate() CLASS TBrowse

   local n

   ::RowCount := ::nBottom - ::nTop + 1 - iif( ::lHeaders, 1, 0 ) - ;
               iif( ::lFooters, 1, 0 ) - iif( Empty( ::HeadSep ), 0, 1 ) - ;
               iif( Empty( ::FootSep ), 0, 1 )

   AFill(::aRedraw, .F. )

   ::Stable := .F.

return Self

METHOD _Right() CLASS TBrowse

   if ::ColPos < ::rightVisible
      ::DeHilite()
      ::ColPos++
      ::Hilite()
   else
      if ::ColPos < Len( ::aColumns )
         ::rightVisible++
         ::leftVisible := ::LeftDetermine()
         ::ColPos++
         ::RefreshAll()
      endif
   endif

return Self


METHOD _Left() CLASS TBrowse

   local leftVis := ::leftVisible

   if ::ColPos > ::leftVisible
      ::DeHilite()
      ::ColPos--
      ::Hilite()
   else
      if ::ColPos <= Max(::leftVisible, ::Freeze) .AND. ::ColPos > 1
         while leftVis == ::leftVisible
            ::rightVisible--
            ::leftVisible := ::LeftDetermine()
         end
         ::ColPos--
         ::RefreshAll()
      endif
   endif

return Self

// 30/09/00 - maurilio.longo@libero.it
//NOTE: I've changed this method but I don't completely understand first if inside it, so
//      I leave it here.
/*METHOD _Left() CLASS TBrowse

   local leftVis := ::leftVisible

   if ::ColPos > ::leftVisible .or. ( ::ColPos < ::leftVisible .and. ::ColPos > 1 ) ;
       .or. ( ::ColPos == ::leftVisible .and. ::Freeze > 0 .and. ::leftVisible  - ::Freeze == 1 )
      ::DeHilite()
      ::ColPos--
      ::Hilite()
   else
      if ::ColPos > 1 .and. ::leftVisible  - ::Freeze > 1
         while leftVis == ::leftVisible
            ::rightVisible--
            ::leftVisible := ::LeftDetermine()
            ::RefreshAll()
         end
         if --::ColPos < ::leftVisible
            ::ColPos := ::rightVisible
         endif
      endif
   endif

return Self*/

METHOD LeftDetermine() CLASS TBrowse

   local nWidthMax := ::nRight - ::nLeft + 1  // Visible width of the browse
   local nWidth := 0
   local nCol

   if ::Freeze > 0
      for nCol := 1 TO ::Freeze
         nWidth += ::aColumns[ nCol ]:Width
         if nCol < Len( ::aColumns )
            nWidth += iif( ::aColumns[ nCol + 1 ]:ColSep != NIL,;
               Len( ::aColumns[ nCol + 1 ]:ColSep ),;
               Len( ::ColSep ) )
         endif
      next
   endif

   for nCol := ::rightVisible to ::Freeze + 1 step -1

      nWidth += ::aColumns[ nCol ]:Width +;
         iif( ::aColumns[ nCol ]:ColSep != NIL,;
            Len( ::aColumns[ nCol ]:ColSep ),;
            Len( ::ColSep ) )

      if nWidth > nWidthMax
         exit
      endif

   next

return nCol + 1

METHOD PageDown() CLASS TBrowse

   local nDown

   ::HitTop := .F.
   if !::HitBottom
      if ( nDown := Eval( ::SkipBlock, ::RowCount )  ) != 0
         if nDown < ::RowCount
            ::RefreshAll()
            ::RowPos += nDown
            ::RelativePos += nDown
         else
            ::RefreshAll()
         endif
      else
         ::HitBottom := .t.
      endif
   endif

return Self

METHOD PageUp() CLASS TBrowse

   local nUp

   ::HitBottom := .F.
   if !::HitTop
      if ( nUp := Abs( Eval( ::SkipBlock, - ::RowCount )  ) ) != 0
         if nUp < ::RowCount
            ::RefreshAll()
            ::RowPos := 1
            ::RelativePos := 1
         else
            ::RefreshAll()
         endif
      else
         ::HitTop := .t.
      endif
   endif

return Self

METHOD PanEnd() CLASS TBrowse

   if ::ColPos < Len( ::aColumns )
      if ::rightVisible < Len( ::aColumns )
         ::rightVisible := Len( ::aColumns )
         ::leftVisible := ::LeftDetermine()
         ::ColPos := ::rightVisible
         ::RefreshAll()
      else
         ::ColPos := ::rightVisible
         ::RefreshCurrent()
      endif
   endif

return Self

METHOD PanHome() CLASS TBrowse

   if ::ColPos > 1
      if ::leftVisible > ::Freeze + 1
         ::leftVisible := ::Freeze + 1
         ::ColPos := 1
         ::RefreshAll()
      else
         ::ColPos := 1
         ::RefreshCurrent()
      endif
   endif

return Self

METHOD PanLeft() CLASS TBrowse

   local n := ::ColPos - ::leftVisible
   local leftVis := ::leftVisible

   if ::leftVisible > ::Freeze + 1
      while leftVis == ::leftVisible
         ::rightVisible--
         ::leftVisible := ::LeftDetermine()
      end
      ::ColPos := Min( ::leftVisible + n, ::rightVisible )
      ::RefreshAll()
   endif

return Self

METHOD PanRight() CLASS TBrowse

   local n := ::ColPos - ::leftVisible

   if ::rightVisible < Len( ::aColumns )
      ::rightVisible++
      ::leftVisible := ::LeftDetermine()
      ::ColPos := Min( ::leftVisible + n, ::rightVisible )
      ::RefreshAll()
   endif

return Self

METHOD DeHilite() CLASS TBrowse

   local nColor := iif( ::aColumns[ ::ColPos ]:ColorBlock != NIL,;
                       Eval( ::aColumns[ ::ColPos ]:ColorBlock,;
                       Eval( ::aColumns[ ::ColPos ]:Block ) )[ 1 ], 1 )
   local cColor := hb_ColorIndex( ::ColorSpec, nColor - 1 )
   local nRow := ::nTop + ::RowPos - iif( ::lHeaders, 0, 1 ) + iif( Empty( ::HeadSep ), 0, 1 )
   local nCol := ::aColumns[ ::ColPos ]:ColPos

   SetPos( nRow, nCol )
   ::DispCell( ::ColPos, cColor )

   // Logical fields are centered on column width
   if ValType(Eval(::aColumns[::ColPos]:Block)) == "L"
      SetPos( nRow, nCol + ::aColumns[::ColPos]:Width / 2)
   else
      SetPos( nRow, nCol )
   endif

return Self

METHOD ForceStable() CLASS TBrowse

   while !::Stabilize()
   end

return Self

METHOD Hilite() CLASS TBrowse

   local nColor
   local cColor
   local nRow
   local nCol

   if ::AutoLite

      nColor := iif( ::aColumns[ ::ColPos ]:ColorBlock != NIL,;
                    Eval( ::aColumns[ ::ColPos ]:ColorBlock,;
                    Eval( ::aColumns[ ::ColPos ]:Block ) )[ 2 ], 2 )
      cColor := hb_ColorIndex( ::ColorSpec, nColor - 1 )
      nRow := ::nTop + ::RowPos - iif( ::lHeaders, 0, 1 ) + iif( Empty( ::HeadSep ), 0, 1 )
      nCol := ::aColumns[ ::ColPos ]:ColPos

      SetPos( nRow, nCol )
      ::DispCell( ::ColPos, cColor )

      if ValType(Eval(::aColumns[::ColPos]:Block)) == "L"
         SetPos( nRow, nCol + ::aColumns[::ColPos]:Width / 2)
      else
         SetPos( nRow, nCol )
      endif

   endif

return Self


METHOD Stabilize() CLASS TBrowse

   local iW, n, nRow, nCol, lDisplay := .t.
   local nWidth := ::nRight - ::nLeft + 1  // Visible width of the browse
   local nColsWidth := 0                   // Total width of visible columns plus ColSep
   local nColsVisible                      // Number of columns that fit on the browse width
   local cColColor                         // Column color to use
   local oCol, oCol2
   local nToAdd

   if Empty(::aRedraw) .or. !::aRedraw[ 1 ]
      // Calculate how many columns fit on the browse width including ColSeps
      if ::Freeze > 0
         if ::leftVisible <= ::Freeze
            ::leftVisible := ::Freeze + 1
         endif

         nColsVisible := 0
         while nColsVisible < ::Freeze

            nToAdd := ::aColumns[ nColsVisible + 1 ]:Width

            if nColsVisible >= 1 .and. nColsVisible < Len( ::aColumns )
               nToAdd += iif( ::aColumns[ nColsVisible + 1 ]:ColSep != NIL,;
                  Len( ::aColumns[ nColsVisible + 1 ]:ColSep ),;
                  Len( ::ColSep ) )
            endif

            if nColsWidth + nToAdd > nWidth
               exit
            endif

            nColsWidth += nToAdd
            nColsVisible++
         enddo

         if nColsWidth > nWidth
            ::Freeze := 0
            nColsWidth := 0
         endif
      endif

      nColsVisible := ::leftVisible - 1

      while nColsVisible < Len( ::aColumns )

         nToAdd := ::aColumns[ nColsVisible + 1 ]:Width

         if nColsVisible >= ::leftVisible .or. ::Freeze > 0
            nToAdd += iif( ::aColumns[ nColsVisible + 1 ]:ColSep != NIL,;
               Len( ::aColumns[ nColsVisible + 1 ]:ColSep ),;
               Len( ::ColSep ) )
         endif

         if nColsWidth + nToAdd > nWidth
            exit
         endif

         nColsWidth += nToAdd
         nColsVisible++
      enddo

      ::rightVisible := nColsVisible

      if Empty(::aRedraw)
         ::RowCount := ::nBottom - ::nTop + 1 - iif( ::lHeaders, 1, 0 ) - ;
               iif( ::lFooters, 1, 0 ) - iif( Empty( ::HeadSep ), 0, 1 ) - iif( Empty( ::FootSep ), 0, 1 )
         ::aRedraw := Array( ::RowCount )
         AFill( ::aRedraw, .F. )
      endif
   else
      oCol := ::aColumns[ iif( ::rightVisible != 0, ::rightVisible, 1 ) ]
      oCol2 := ::aColumns[ iif( ::Freeze > 0, 1, ::leftVisible ) ]
      nColsWidth := iif( oCol != NIL, oCol:ColPos, 0 ) + ;
        iif( oCol != NIL, oCol:Width, 0 ) - oCol2:ColPos

      /* NOTE: 01/01/2000 - maurilio.longo@libero.it
               Should not be needed anymore. */
      /*::lFooters := ( ::RowCount != ::nBottom - ::nTop + 1 - iif( ::lHeaders, 1, 0 ) - ;
                - iif( Empty( ::HeadSep ), 0, 1 ) - iif( Empty( ::FootSep ), 0, 1 ) )*/
   endif

   if !::aRedraw[ 1 ]
      if ::lHeaders          // Drawing headers
         DispOutAt( ::nTop, ::nLeft, Space( ( nWidth - nColsWidth ) / 2 ), ::ColorSpec )
         for n := iif(::Freeze > 0, 1, ::leftVisible) to ::rightVisible
            if ::Freeze > 0 .and. n == ::Freeze + 1
               n := ::leftVisible
            endif
            DispOut( PadR( ::aColumns[ n ]:Heading, ::aColumns[ n ]:Width ), ::ColorSpec )
            if n < ::rightVisible
               DispOut( Space( iif( ::aColumns[ n + 1 ]:ColSep != NIL, ;
                 Len( ::aColumns[ n + 1 ]:ColSep ), Len( ::ColSep ) ) ), ::ColorSpec )
            endif
         next

         // Every time there is some space to fill up and this space is an odd number of chars we need to
         // round it up to next value here since first DispOutAt() does round it down because it uses a simple
         // division (ie Space(7/2) gives 3 on first call and 4 here).
         DispOut(Space(Int(Round((nWidth - nColsWidth) / 2, 0))), ::ColorSpec)
      endif
      if ! Empty( ::HeadSep )  //Drawing heading separator
         DispOutAt( ::nTop + iif( ::lHeaders, 1, 0 ), ::nLeft, Replicate( Right( ::HeadSep, 1 ), ( nWidth - nColsWidth ) / 2 ), ::ColorSpec )
         if Len( ::HeadSep ) > 1
            iW := 0
            for n := iif( ::Freeze > 0, 1, ::leftVisible ) to ::rightVisible
               if ::Freeze > 0 .and. n == ::Freeze + 1
                  n := ::leftVisible
               endif
               DispOut( Replicate( Right( ::HeadSep, 1 ), ::aColumns[ n ]:Width - iW ), ::ColorSpec )
               if n < ::rightVisible
                  DispOut( Left( ::HeadSep, Len( ::HeadSep ) - 1 ), ::ColorSpec )
                  iW := Len( ::HeadSep ) - 1 - iif( ::aColumns[ n + 1 ]:ColSep != NIL, ;
                      Len( ::aColumns[ n + 1 ]:ColSep ), Len( ::ColSep ) )
               endif
            next
         else
            DispOut( Replicate( ::HeadSep, nColsWidth ), ::ColorSpec )
         endif
         DispOut( Replicate( Right( ::HeadSep, 1 ), ( nWidth - nColsWidth ) / 2 ), ::ColorSpec )
      endif
      if ! Empty( ::FootSep ) // Drawing footing separator
         DispOutAt( ::nBottom - iif( ::lFooters, 1, 0 ), ::nLeft, Replicate( Right( ::FootSep, 1 ), ( nWidth - nColsWidth ) / 2 ), ::ColorSpec )
         if Len( ::FootSep ) > 1
            iW := 0
            for n := iif( ::Freeze > 0, 1, ::leftVisible ) to ::rightVisible
               if ::Freeze > 0 .and. n == ::Freeze + 1
                  n := ::leftVisible
               endif
               DispOut( Replicate( Right( ::FootSep, 1 ), ::aColumns[ n ]:Width - iW ), ::ColorSpec )
               if n < ::rightVisible
                  DispOut( Left( ::FootSep, Len( ::FootSep ) - 1 ), ::ColorSpec )
                  iW := Len( ::FootSep ) - 1 - iif( ::aColumns[ n + 1 ]:ColSep != NIL, ;
                      Len( ::aColumns[ n + 1 ]:ColSep ), Len( ::ColSep ) )
               endif
            next
         else
            DispOut( Replicate( ::FootSep, nColsWidth ), ::ColorSpec )
         endif
         DispOut( Replicate( Right( ::FootSep, 1 ), ( nWidth - nColsWidth ) / 2 ), ::ColorSpec )
      endif
      if ::lFooters                // Drawing footers
         DispOutAt( ::nBottom, ::nLeft, Space( ( nWidth - nColsWidth ) / 2 ), ::ColorSpec )
         for n := iif( ::Freeze > 0, 1, ::leftVisible ) to ::rightVisible
               if ::Freeze > 0 .and. n == ::Freeze + 1
                  n := ::leftVisible
               endif
            DispOut( PadR( ::aColumns[ n ]:Footing, ::aColumns[ n ]:Width ), ::ColorSpec )
            if n < ::rightVisible
               DispOut( Space( iif( ::aColumns[ n + 1 ]:ColSep != NIL, ;
                 Len( ::aColumns[ n + 1 ]:ColSep ), Len( ::ColSep ) ) ), ::ColorSpec )
            endif
         next
         DispOut(Space(Int(Round((nWidth - nColsWidth) / 2, 0))), ::ColorSpec)
      endif
   endif

   for nRow := 1 to ::RowCount    // Looking for row to redraw
      if !::aRedraw[ nRow ]
         ::aRedraw[ nRow ] := .T.
         exit
      endif
   next

   if nRow > ::RowCount          // if all rows are draw, hilite current
      if !::stable
         Eval( ::SkipBlock, ::RowPos - ::RelativePos )
         ::RelativePos := ::RowPos
         ::HitBottom := .F.
         ::stable := .t.
      endif
      // NOTE: DBU relies upon current cell being reHilite()d even if it is already stable
      ::HiLite()
      return .t.
   else             // redraw a row
      if !::HitBottom
         if nRow != ::RelativePos
            if lDisplay := ( Eval( ::SkipBlock, nRow - ::RelativePos ) != 0 )
               ::RelativePos := nRow
            else
               ::HitBottom := .T.
            endif
         endif
      else
         lDisplay := .F.
      endif

      DispOutAt( ::nTop + nRow + iif( ::lHeaders, 0, -1 ) + iif( Empty( ::HeadSep ), 0, 1 ), ::nLeft,;
         Space( ( nWidth - nColsWidth ) / 2 ), ::ColorSpec )

      for n := iif( ::Freeze > 0, 1, ::leftVisible ) to ::rightVisible

         if ::Freeze > 0 .and. n == ::Freeze + 1
            n := ::leftVisible
         endif
         if nRow == 1
            ::aColumns[ n ]:ColPos := Col()
         endif

         nCol := Col()

         if lDisplay

            cColColor := iif( ::aColumns[ n ]:ColorBlock != NIL,;
                             hb_ColorIndex( ::ColorSpec,;
                             Eval( ::aColumns[ n ]:ColorBlock,;
                             Eval( ::aColumns[ n ]:Block ) )[ 1 ] - 1 ),;
                             ::ColorSpec )

            ::DispCell( n, cColColor )
            SetPos( Row(), nCol + ::aColumns[ n ]:Width )
         else
            DispOut( Space( ::aColumns[ n ]:Width ), ::ColorSpec )
         endif

         if n < ::rightVisible
            if ::aColumns[ n + 1 ]:ColSep != NIL
               DispOut( ::aColumns[ n + 1 ]:ColSep, ::ColorSpec )
            elseif ::ColSep != NIL
               DispOut( ::ColSep, ::ColorSpec )
            endif
         endif
      next

      DispOut(Space(Int(Round((nWidth - nColsWidth) / 2, 0))), ::ColorSpec)

   endif

return .f.

METHOD Up() CLASS TBrowse

   local n

   ::HitBottom := .F.
   if !::HitTop
      ::DeHilite()
      if Eval( ::SkipBlock, -1 ) != 0
         if ::RowPos > 1
            ::RowPos--
            ::Hilite()
            ::RelativePos--
         else
            n := ::nTop + iif( ::lHeaders, 1, 0 ) + iif( Empty( ::HeadSep ), 0, 1 )
            Scroll( n, ::nLeft, n + ::RowCount - 1, ::nRight, -1 )
            ::RefreshCurrent()
         endif
      else
         ::Hilite()
         ::HitTop := .t.
      endif
   endif

return Self

METHOD ColorRect( aRect, aRectColor ) CLASS TBrowse

   ::aRect       := aRect
   ::aRectColor  := aRectColor

return Self

METHOD DispCell( nColumn, cColor ) CLASS TBrowse

   LOCAL ftmp := Eval( ::aColumns[ nColumn ]:block )
   LOCAL nCol := Col()

   do case
   case valtype( ftmp ) $ "CM"
      DispOut( Left( ftmp, ::aColumns[ nColumn ]:Width ), cColor )

   case valtype( ftmp ) == "N"
      DispOut( Right( Str( ftmp ), ::aColumns[ nColumn ]:Width ), cColor )

   case valtype( ftmp ) == "D"
      DispOut( Right( DToC( ftmp ), ::aColumns[ nColumn ]:Width ), cColor )

   case valtype( ftmp ) == "L"
      DispOut( Space( ::aColumns[ nColumn ]:Width / 2 ), ::ColorSpec )
      DispOut( iif( ftmp, "T","F" ), cColor )

   endcase

   DispOut( Space( nCol + ::aColumns[ nColumn ]:Width - Col() ), ::ColorSpec )

return Self
#ifdef HB_COMPAT_C53
method applykey(nKey)  CLASS TBrowse
return ::tapplykey(nKey, self)

method initKeys(o) CLASS TBROWSE

   Default o:aKeys to {{K_DOWN,{|Ob,nKey| Ob:Down(),0}},;
              {K_END,{|Ob,nKey| Ob:End(),0}},;
              {K_CTRL_PGDN,{|Ob,nKey| Ob:GoBottom(),0}},;
              {K_CTRL_PGUP,{|Ob,nKey| Ob:GoTop(),0}},;
              {K_HOME,{|Ob,nKey| Ob:Home(),0}},;
              {K_LEFT,{|Ob,nKey| Ob:Left(),0}},;
              {K_PGDN,{|Ob,nKey| Ob:PageDown(),0}},;
              {K_PGUP,{|Ob,nKey| Ob:PageUp(),0}},;
              {K_CTRL_END,{|Ob,nKey| Ob:PanEnd(),0}},;
              {K_CTRL_HOME,{|Ob,nKey| Ob:PanHome(),0}},;
              {K_CTRL_LEFT,{|Ob,nKey| Ob:PanLeft(),0}},;
              {K_CTRL_RIGHT,{|Ob,nKey| Ob:PanRight(),0}},;
              {K_RIGHT,{|Ob,nKey| Ob:Right(),0}},;
              {K_UP,{|Ob,nKey| Ob:Up(),0}},;
              {K_ESC,{|Ob,nKey| -1 }}}         
return o

Method SetKey(nKey,bBlock) CLASS TBrowse
local bReturn,nPos
::initKeys(self)
if (nPos:=ascan(::aKeys,{|x| x[1]==nkey}))==0
      if ( ISBLOCK( bBlock ) )
         bReturn:= bBlock
         aadd(::aKeys,{nKey,bBlock})
   endif
   bReturn:=bBlock
elseif (ISBLOCK(bBlock))
    ::aKeys[npos][2]:=bBlock
   bReturn:=bBlock
elseif PCOUNT()==1
   bReturn:= ::aKeys[npos][2]
elseif ( bReturn:= ::aKeys[ nPos ][ 2 ], PCount() == 2 .AND. ;
         ISNIL( bBlock ) .AND. nKey != 0 )
      adel(::aKeys, nPos)
      asize(::akeys, Len(::aKeys) - 1)
endif
return bReturn
method TAPPLYKEY( nKey, oBrowse ) CLASS tBrowse

   local bBlock := oBrowse:setkey(nKey), nReturn
   default bBlock to oBrowse:setkey(0)
   if ( ISNIL( bBlock ) )
      nReturn := 1
   else
      nReturn := eval(bBlock, oBrowse, nKey)
   endif
   return nReturn


#endif
function TBrowseNew(nTop, nLeft, nBottom, nRight)

return TBrowse():New(nTop, nLeft, nBottom, nRight)

