#
# $Id$
#

ROOT = ../../

LIBNAME=hbhpdf

ifneq ($(HB_ARCHITECTURE),dos)

ifeq ($(HB_INC_LIBHARU),)
ifeq ($(HB_XBUILD),)
HB_INC_LIBHARU = /usr/include /usr/local/include
endif
endif

HB_INC_LIBHARU_OK += $(foreach d, $(HB_INC_LIBHARU), $(if $(wildcard $(d)/hpdf.h),$(d),))

ifneq ($(strip $(HB_INC_LIBHARU_OK)),)

C_USR += $(foreach d, $(HB_INC_LIBHARU_OK), -I$(d))

C_SOURCES=\
	harupdf.c \

PRG_HEADERS=\
	harupdf.ch \

PRG_SOURCES=\

include $(TOP)$(ROOT)config/header.cf
INSTALL_RULE_HEADERS := $(INSTALL_RULE)
include $(TOP)$(ROOT)config/lib.cf

install::
	$(INSTALL_RULE_HEADERS)

else
include $(TOP)$(ROOT)config/none.cf
endif
else
include $(TOP)$(ROOT)config/none.cf
endif
