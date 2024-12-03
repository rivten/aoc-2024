#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "helpers.h"

struct solver {
    int expr;
    bool apply_mult;
    long total;
    long diff;
};

static __attribute__((nonnull))
char *parse_multiplication(char *s, int *expr)
{
    int left;
    int right;
    char *endp;

    *expr = 0;
    s = strstr(s, "mul");
    if (s == NULL)
        return NULL;
    s += lengthof("mul");
    if (*s != '(')
        return s;
    left = strtol(s + 1, &endp, 10);
    if (s == endp || *endp != ',')
        return s;
    right = strtol(endp + 1, &endp, 10);
    if (s != endp && *endp == ')')
        *expr = left * right;
    return endp + 1;
}

static
bool parse_conditionnal(char *from, char const *to, bool state)
{
    char *apply = NULL;
    char *cancel = NULL;
    char *prev;
    bool proceed = state;

    do {
        prev = from;
        apply = strstr(from, "do()");
        if (apply < to && apply != NULL) {
            proceed = true;
            from = apply + 1;
        }
        cancel = strstr(from, "don't()");
        if (cancel < to && cancel != NULL) {
            proceed = false;
            from = cancel + 1;
        }
    } while (prev != from);
    return proceed;
}

int main(void)
{
    char *input = NULL;
    int status = EXIT_FAILURE;
    struct solver sol = { .total = 0, .apply_mult = true };

    if (!read_file("input", &input))
        goto stop;

    for (char *save = input; input != NULL; save = input) {
        input = parse_multiplication(input, &sol.expr);
        sol.total += sol.expr;

        sol.apply_mult = parse_conditionnal(save, input, sol.apply_mult);
        if (!sol.apply_mult)
            sol.diff += sol.expr;
    }

    printf("Part 1: %ld\n", sol.total);
    printf("Part 2: %ld\n", sol.total - sol.diff);
    status = EXIT_SUCCESS;

    stop:
        free(input);
        return status;
}
