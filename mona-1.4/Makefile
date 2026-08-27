# Static build for the vendored Mona 1.4 (replaces autotools).
# HIP only needs bin/mona; generated parser.cpp/scanner.cpp are tracked,
# so bison/flex are not required.
# ponytail: no portability probing — config.h is a committed Linux config;
# if another platform is ever needed, regenerate it with autoconf upstream.

CXXFLAGS = -O2 -I. -I BDD
CFLAGS   = -O2 -I. -I BDD

SRCS := $(wildcard Front/*.cpp Mem/*.c BDD/*.c DFA/*.c GTA/*.c)
OBJS := $(patsubst %.cpp,obj/%.o,$(filter %.cpp,$(SRCS))) \
        $(patsubst %.c,obj/%.o,$(filter %.c,$(SRCS)))

bin/mona: $(OBJS)
	@mkdir -p bin
	$(CXX) $(CXXFLAGS) -o $@ $(OBJS)

obj/%.o: %.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@

obj/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -rf obj bin

.PHONY: clean
