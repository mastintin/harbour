/*
 * $Id$
 */

/*
 * Harbour Project source code:
 * Header file for compiler error codes
 *
 * Copyright 1999 Ryszard Glab <rglab@imid.med.pl>
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

#ifndef HB_ERRORS_H_
#define HB_ERRORS_H_

#if defined(__cplusplus)
extern "C" {
#endif

/*
 * Errors generated by Harbour compiler
 */
#define HB_COMP_ERR_OUTSIDE                     1
#define HB_COMP_ERR_FUNC_DUPL                   2
#define HB_COMP_ERR_VAR_DUPL                    3
#define HB_COMP_ERR_FOLLOWS_EXEC                4
#define HB_COMP_ERR_OUTER_VAR                   5
#define HB_COMP_ERR_NUMERIC_FORMAT              6
#define HB_COMP_ERR_STRING_TERMINATOR           7
#define HB_COMP_ERR_FUNC_RESERVED               8
#define HB_COMP_ERR_ILLEGAL_INIT                9
#define HB_COMP_ERR_ENDIF                       10
#define HB_COMP_ERR_ENDDO                       11
#define HB_COMP_ERR_ENDCASE                     12
#define HB_COMP_ERR_NEXTFOR                     13
#define HB_COMP_ERR_UNMATCHED_ELSE              14
#define HB_COMP_ERR_UNMATCHED_ELSEIF            15
#define HB_COMP_ERR_SYNTAX                      16
#define HB_COMP_ERR_UNCLOSED_STRU               17
#define HB_COMP_ERR_UNMATCHED_EXIT              18
#define HB_COMP_ERR_SYNTAX2                     19
#define HB_COMP_ERR_INCOMPLETE_STMT             20
#define HB_COMP_ERR_CHECKING_ARGS               21
#define HB_COMP_ERR_INVALID_LVALUE              22
#define HB_COMP_ERR_INVALID_REFER               23
#define HB_COMP_ERR_PARAMETERS_NOT_ALLOWED      24
#define HB_COMP_ERR_EXIT_IN_SEQUENCE            25
#define HB_COMP_ERR_UNTERM_ARRAY_INDEX          26
#define HB_COMP_ERR_MEMALLOC                    27
#define HB_COMP_ERR_MEMREALLOC                  28
#define HB_COMP_ERR_MEMFREE                     29
#define HB_COMP_ERR_YACC                        30
#define HB_COMP_ERR_JUMP_TOO_LONG               31
#define HB_COMP_ERR_CREATE_OUTPUT               32
#define HB_COMP_ERR_CREATE_PPO                  33
#define HB_COMP_ERR_BADOPTION                   34
#define HB_COMP_ERR_BADPARAM                    35
#define HB_COMP_ERR_BADFILENAME                 36
#define HB_COMP_ERR_MAYHEM_IN_CASE              37
#define HB_COMP_ERR_INVALID_TYPE                38
#define HB_COMP_ERR_INVALID_ALIAS               39
#define HB_COMP_ERR_INVALID_INDEX               40
#define HB_COMP_ERR_INVALID_BOUND               41
#define HB_COMP_ERR_BAD_MACRO                   42
#define HB_COMP_ERR_INVALID_SEND                43
#define HB_COMP_ERR_FUNC_ANNOUNCE               44

#define HB_COMP_WARN_AMBIGUOUS_VAR              1
#define HB_COMP_WARN_MEMVAR_ASSUMED             2
#define HB_COMP_WARN_VAR_NOT_USED               3
#define HB_COMP_WARN_BLOCKVAR_NOT_USED          4
#define HB_COMP_WARN_NO_RETURN_VALUE            5
#define HB_COMP_WARN_PROC_RETURN_VALUE          6
#define HB_COMP_WARN_FUN_WITH_NO_RETURN         7
#define HB_COMP_WARN_ASSIGN_TYPE                8
#define HB_COMP_WARN_LOGICAL_TYPE               9
#define HB_COMP_WARN_NUMERIC_TYPE               10
#define HB_COMP_WARN_OPERANDS_INCOMPATBLE       11
#define HB_COMP_WARN_ASSIGN_SUSPECT             12
#define HB_COMP_WARN_OPERAND_SUSPECT            13
#define HB_COMP_WARN_LOGICAL_SUSPECT            14
#define HB_COMP_WARN_NUMERIC_SUSPECT            15
#define HB_COMP_WARN_MEANINGLESS                16
#define HB_COMP_WARN_UNREACHABLE                17
#define HB_COMP_WARN_DUPL_ANNOUNCE              18

/*
 * Errors generated by Harbour preprocessor
 */
#define HB_PP_ERR_CANNOT_OPEN                   1
#define HB_PP_ERR_DIRECTIVE_ELSE                2
#define HB_PP_ERR_DIRECTIVE_ENDIF               3
#define HB_PP_ERR_WRONG_NAME                    4
#define HB_PP_ERR_DEFINE_ABSENT                 5
#define HB_PP_ERR_COMMAND_DEFINITION            6
#define HB_PP_ERR_PATTERN_DEFINITION            7
#define HB_PP_ERR_RECURSE                       8
#define HB_PP_ERR_WRONG_DIRECTIVE               9
#define HB_PP_ERR_EXPLICIT                      10
#define HB_PP_ERR_MEMALLOC                      11
#define HB_PP_ERR_MEMREALLOC                    12
#define HB_PP_ERR_MEMFREE                       13
#define HB_PP_ERR_PRAGMA_BAD_VALUE              14

#define HB_PP_WARN_DEFINE_REDEF                 1

extern void hb_compGenError( char * _szErrors[], char cPrefix, int iError, char * szError1, char * szError2 ); /* generic parsing error management function */
extern void hb_compGenWarning( char * _szWarnings[], char cPrefix, int iWarning, char * szWarning1, char * szWarning2); /* generic parsing warning management function */

#if defined(__cplusplus)
}
#endif

#endif /* HB_ERRORS_H_ */
