LLVMPATH=/Users/yixin/github/compiler/llvm

FLAGS=-I${LLVMPATH}/include -Wno-deprecated-register -std=c++11

LLVMCONFIG = ${LLVMPATH}/bin/llvm-config
CPPFLAGS = `$(LLVMCONFIG) --cppflags` -std=c++11
LDFLAGS = `$(LLVMCONFIG) --ldflags` -lpthread -ldl -lz -lncurses -rdynamic
LIBS = `$(LLVMCONFIG) --libs`


all: kale_parser

OBJS = parser.o  \
       codegen.o \
       main.o    \
       tokens.o  \
       corefn.o  \
	   native.o  \

parser.cpp: parser.y
	bison -d -o $@ $^
	
parser.hpp: parser.cpp

tokens.cpp: tokens.l parser.hpp
	flex -o $@ $^

%.o: %.cpp
	g++ -c $(CPPFLAGS) -o $@ $<

kale_parser: $(OBJS)
	g++ -o $@ $(OBJS) $(LIBS) $(LDFLAGS) ${FLAGS}

test: kale_parser example.txt
	cat example.txt | ./kale_parser

clean:
	$(RM) -rf parser.cpp parser.hpp tokens.cpp kale_parser $(OBJS)
