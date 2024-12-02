TARGET := day02-solution

ROOT := day02.zig
SRCS := $(ROOT) aoc.zig
OBJS := $(TARGET).o

CWD := $(shell pwd)

ZC := zig
ZFLAGS := -ODebug
TEST_ZFLAGS := -ODebug

$(TARGET): $(SRCS)
	$(ZC) build-exe $(ZFLAGS) -Mroot="$(CWD)/$(ROOT)" --cache-dir "$(PWD)/.zig-cache" --name $@

run: $(TARGET)
	./$(TARGET)

test: $(SRCS)
	$(ZC) test $(TEST_ZFLAGS) -Mroot="$(CWD)/$(ROOT)" --cache-dir "$(PWD)/.zig-cache" --name test

clean:
	rm -f $(TARGET) $(TEST_TARGET) $(OBJS)

.PHONY: run clean
