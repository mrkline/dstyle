# https://gist.github.com/darkstalker/2221824
# basic makefile for D language - made by darkstalker

DCC = dmd
DFLAGS += -wi
LIBS =
SRC = $(wildcard *.d)
OBJ = $(SRC:.d=.o)
OUT = $(shell basename `pwd`)

.PHONY: all debug release profile clean

all: debug

debug:   DFLAGS += -g -debug -unittest
release: DFLAGS += -O -release -inline -noboundscheck
profile: DFLAGS += -g -O -profile

debug release profile: $(OUT)

$(OUT): $(OBJ)
	$(DCC) $(DFLAGS) -of$@ $(OBJ) $(LIBS)

clean:
	rm -f *~ $(OBJ) $(OUT) trace.{def,log}

%.o: %.d
	$(DCC) $(DFLAGS) -c $<
