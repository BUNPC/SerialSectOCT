
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

PROG = ATS9360_NPT_AverageMultithreaded
OBJS = ATS9360_NPT_AverageMultithreaded.o

$(PROG) : $(OBJS)
	$(CC) -o $(PROG) $(OBJS) $(LIBS)

ATS9360_NPT_AverageMultithreaded.o : ATS9360_NPT_AverageMultithreaded.cpp
	$(CC) -c $(CFLAGS) ATS9360_NPT_AverageMultithreaded.cpp

clean :
	rm -f $(PROG) *.o *~