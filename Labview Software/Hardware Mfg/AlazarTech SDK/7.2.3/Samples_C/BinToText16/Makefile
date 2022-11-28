src = BinToText16.cpp
obj = $(src:.c=.o)

BinToText16: $(obj)
	$(CXX) -o $@ $^

.PHONY: clean
clean:
	rm -f $(obj) myprog
DFLAGS = -lGL -lglut -lpng -lz -lm
