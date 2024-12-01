OUT := day01

CFLAGS += -O2
CFLAGS += -std=c99 -pedantic -D_POSIX_SOURCE
CFLAGS += @_base_warnings

$(OUT): $(shell find . -type f -name "*.c")
	$(CC) -o $@ $(CFLAGS) $^ $(LDFLAGS) $(LDLIBS)

fclean:
	$(RM) $(OUT)

.NOTPARALLEL: re
re: fclean $(OUT)

.PHONY: fclean re
