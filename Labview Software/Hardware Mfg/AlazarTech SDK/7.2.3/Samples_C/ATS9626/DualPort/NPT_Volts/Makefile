
CC := g++
PLX_OPT := $(PLX_OPT) -DPCI_CODE -DPLX_LITTLE_ENDIAN -DPLX_LINUX

# DEBUG := 1
ifdef DEBUG
   CC_OPT := $(CC_OPT) -g3
   PLX_OPT := $(PLX_OPT) -DPLX_DEBUG
else
   CC_OPT := $(CC_OPT) -O2
endif

CFLAGS := $(CFLAGS) -c -Wall $(CC_OPT) $(PLX_OPT)
LIBS := $(LIBS) -lATSApi

PROG = ATS9626_NPT_Volts
OBJS = ATS9626_NPT_Volts.o

$(PROG) : $(OBJS)
	$(CC) -o $(PROG) $(OBJS) $(LIBS)

ATS9626_NPT_Volts.o : ATS9626_NPT_Volts.cpp
	$(CC) -c $(CFLAGS) ATS9626_NPT_Volts.cpp

clean :
	rm -f $(PROG) *.o *~