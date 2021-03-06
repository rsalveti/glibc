/* CPU specific memcpy implementations.  64 bit S/390 version.
   Copyright (C) 2012-2016 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, see
   <http://www.gnu.org/licenses/>.  */


#include "sysdep.h"
#include "asm-syntax.h"

/* INPUT PARAMETERS
     %r2 = target operands address
     %r3 = source operands address
     %r4 = number of bytes to copy.  */

       .text

#if defined SHARED && IS_IN (libc)

ENTRY(____mempcpy_z196)
	.machine "z196"
	lgr     %r1,%r2         # Use as dest
	la      %r2,0(%r4,%r2)  # Return dest + n
	j	.L_Z196_start
END(____mempcpy_z196)

ENTRY(__memcpy_z196)
	.machine "z196"
	lgr     %r1,%r2         # r1: Use as dest ; r2: Return dest
.L_Z196_start:
	ltgr    %r4,%r4
	je      .L_Z196_4
	aghi    %r4,-1
	srlg    %r5,%r4,8
	ltgr    %r5,%r5
	jne     .L_Z196_5
.L_Z196_3:
	exrl    %r4,.L_Z196_14
.L_Z196_4:
	br      %r14
.L_Z196_5:
	cgfi    %r5,262144      # Switch to mvcle for copies >64MB
	jh      __memcpy_mvcle
.L_Z196_2:
	pfd     1,768(%r3)
	pfd     2,768(%r1)
	mvc     0(256,%r1),0(%r3)
	aghi    %r5,-1
	la      %r1,256(%r1)
	la      %r3,256(%r3)
	jne     .L_Z196_2
	j       .L_Z196_3
.L_Z196_14:
	mvc     0(1,%r1),0(%r3)
END(__memcpy_z196)

ENTRY(____mempcpy_z10)
	.machine "z10"
	lgr     %r1,%r2         # Use as dest
	la      %r2,0(%r4,%r2)  # Return dest + n
	j	.L_Z10_start
END(____mempcpy_z10)

ENTRY(__memcpy_z10)
	.machine "z10"
	lgr     %r1,%r2         # r1: Use as dest ; r2: Return dest
.L_Z10_start:
	cgije   %r4,0,.L_Z10_4
	aghi    %r4,-1
	srlg    %r5,%r4,8
	cgijlh  %r5,0,.L_Z10_13
.L_Z10_3:
	exrl    %r4,.L_Z10_15
.L_Z10_4:
	br      %r14
.L_Z10_13:
	cgfi    %r5,65535	# Switch to mvcle for copies >16MB
	jh      __memcpy_mvcle
.L_Z10_12:
	pfd     1,768(%r3)
	pfd     2,768(%r1)
	mvc     0(256,%r1),0(%r3)
	la      %r1,256(%r1)
	la      %r3,256(%r3)
	brctg   %r5,.L_Z10_12
	j       .L_Z10_3
.L_Z10_15:
	mvc     0(1,%r1),0(%r3)
END(__memcpy_z10)

# define __mempcpy ____mempcpy_default
#endif /* SHARED && IS_IN (libc) */

#define memcpy __memcpy_default
#include "../memcpy.S"
#undef memcpy

#if defined SHARED && IS_IN (libc)
.globl   __GI_memcpy
.set     __GI_memcpy,__memcpy_default
.globl   __GI_mempcpy
.set     __GI_mempcpy,____mempcpy_default
.globl   __GI___mempcpy
.set     __GI___mempcpy,____mempcpy_default
#else
.globl   memcpy
.set     memcpy,__memcpy_default
.weak    mempcpy
.set     mempcpy,__mempcpy
#endif
