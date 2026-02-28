TARGET=main

HEADERS=$(wildcard *.h) API_KEY

SRCS=$(wildcard *.cpp)

PKG_LIB_NAMES=libcrypto

# flags passed to C++ preprocessor
MANUAL_CPPFLAGS=$(shell curl-config --cflags)

# flags passed to C++ compiler
MANUAL_CXXFLAGS=-Wall -Wextra -pedantic-errors -std=c++14

# non-library flags passed to linker
MANUAL_LDFLAGS=

# library flags passed to linker
MANUAL_LDLIBS=$(shell curl-config --libs) -lboost_json

####################################################
# You will unlikey need to modify the content below.
####################################################

OBJS=$(patsubst %.cpp,%.o,$(SRCS))

CPPFLAGS=$(shell pkg-config --cflags $(PKG_LIB_NAMES)) $(MANUAL_CPPFLAGS)

CXXFLAGS=$(MANUAL_CXXFLAGS)

LDFLAGS=$(shell pkg-config --libs-only-L --libs-only-other $(PKG_LIB_NAMES)) \
	$(MANUAL_LDFLAGS)

LDLIBS=$(shell pkg-config --libs-only-l $(PKG_LIB_NAMES)) $(MANUAL_LDLIBS)

DEPEND=depend

all: $(TARGET)

$(DEPEND): $(HEADERS) $(SRCS)
	@echo Making dependency graph...
	$(CXX) $(CPPFLAGS) -MM $(SRCS) >$@
	@echo

include $(DEPEND)

%.o: %.cpp
	@echo Compiling source file...
	@echo Dependencies: $^
	$(CXX) -o $@ $(CPPFLAGS) $(CXXFLAGS) -c $<
	@echo

$(TARGET): $(OBJS)
	@echo Linking object files...
	$(CXX) -o $@ $(LDFLAGS) $^ $(LDLIBS)
	@echo

clean:
	$(RM) $(DEPEND) $(OBJS) $(TARGET)

.PHONY: all clean

