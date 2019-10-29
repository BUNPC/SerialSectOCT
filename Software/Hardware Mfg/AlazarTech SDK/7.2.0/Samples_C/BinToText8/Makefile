src = BinToText8.cpp
obj = $(src:.c=.o)

BinToText8: $(obj)
	$(CXX) -o $@ $^

.PHONY: clean
clean:
	rm -f $(obj) myprog
