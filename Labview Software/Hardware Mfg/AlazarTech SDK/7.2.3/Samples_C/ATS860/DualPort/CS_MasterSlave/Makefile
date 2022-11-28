
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

PROG = ATS860_CS_MasterSlave
OBJS = ATS860_CS_MasterSlave.o

$(PROG) : $(OBJS)
	$(CC) -o $(PROG) $(OBJS) $(LIBS)

ATS860_CS_MasterSlave.o : ATS860_CS_MasterSlave.cpp
	$(CC) -c $(CFLAGS) ATS860_CS_MasterSlave.cpp

clean :
	rm -f $(PROG) *.o *~