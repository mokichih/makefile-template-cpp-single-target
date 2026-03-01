TARGET=main

HDRS=$(wildcard *.h) API_KEY

SRCS=$(wildcard *.cpp)

PKG_LIBS=libcrypto

CXX=g++

# flags passed to C++ preprocessor
CPPFLAGS=$(shell curl-config --cflags)

# flags passed to C++ compiler
CXXFLAGS=-Wall -Wextra -pedantic-errors -std=c++14 -O3

# non-library flags passed to linker
LDFLAGS=

# library flags passed to linker
LDLIBS=$(shell curl-config --libs) -lboost_json

#######################################################
# You are unlikely to need to modify the content below.
#######################################################

OBJS=$(patsubst %.cpp,%.o,$(SRCS))

EFFECTIVE_CPPFLAGS=$(shell pkg-config --cflags $(PKG_LIBS)) $(CPPFLAGS)

EFFECTIVE_CXXFLAGS=$(CXXFLAGS)

EFFECTIVE_LDFLAGS=$(shell pkg-config --libs-only-L --libs-only-other \
		  $(PKG_LIBS)) $(LDFLAGS)

EFFECTIVE_LDLIBS=$(shell pkg-config --libs-only-l $(PKG_LIBS)) $(LDLIBS)

DEPEND=depend

all: $(TARGET)

$(DEPEND): $(HDRS) $(SRCS)
	@echo Making dependency graph...
	$(CXX) $(EFFECTIVE_CPPFLAGS) -MM $(SRCS) >$@
	@echo

include $(DEPEND)

%.o: %.cpp
	@echo Compiling source file...
	@echo Dependencies: $^
	$(CXX) -o $@ $(EFFECTIVE_CPPFLAGS) $(EFFECTIVE_CXXFLAGS) -c $<
	@echo

$(TARGET): $(OBJS)
	@echo Linking object files...
	$(CXX) -o $@ $(EFFECTIVE_LDFLAGS) $^ $(EFFECTIVE_LDLIBS)
	@echo

clean:
	$(RM) $(DEPEND) $(OBJS) $(TARGET)

.PHONY: all clean

