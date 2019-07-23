# -*- mode: makefile-gmake -*-

all:
.PHONY: all

all: test/bin-test/test1.exe
test/bin-%/test1.exe: test1.exe
	cp $< $@
test1.exe: test1.o
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $^
