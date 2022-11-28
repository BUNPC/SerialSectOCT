
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

PROG = ATS460_CS_WaitNextBuffer
OBJS = ATS460_CS_WaitNextBuffer.o

$(PROG) : $(OBJS)
	$(CC) -o $(PROG) $(OBJS) $(LIBS)

ATS460_CS_WaitNextBuffer.o : ATS460_CS_WaitNextBuffer.cpp
	$(CC) -c $(CFLAGS) ATS460_CS_WaitNextBuffer.cpp

clean :
	rm -f $(PROG) *.o *~