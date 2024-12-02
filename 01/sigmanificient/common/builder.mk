OUT := day$(lastword $(subst /, ,$(dir $(PWD))))
/ := ../../01/sigmanificient/common/

CFLAGS += -std=c99 -pedantic -D_POSIX_SOURCE
CFLAGS += -iquote $/
CFLAGS += -O2

CFLAGS += @$/base_warnings

$(OUT): $(shell find . -type f -name "*.c") $/read_file.c
	$(CC) -o $@ $(CFLAGS) $^ $(LDFLAGS) $(LDLIBS)

fclean:
	$(RM) $(OUT)

.NOTPARALLEL: re
re: fclean $(OUT)

.PHONY: fclean re
