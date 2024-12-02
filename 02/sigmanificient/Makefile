OUT := day02

CFLAGS += -g3 -fsanitize=address,leak,undefined

CFLAGS += -O2
CFLAGS += -std=c99 -pedantic -D_POSIX_SOURCE
CFLAGS += @_base_warnings

$(OUT): $(shell find . -type f -name "*.c") ../../01/sigmanificient/read_file.c
	$(CC) -o $@ $(CFLAGS) $^ $(LDFLAGS) $(LDLIBS)

fclean:
	$(RM) $(OUT)

.NOTPARALLEL: re
re: fclean $(OUT)

.PHONY: fclean re
