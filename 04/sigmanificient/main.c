#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "helpers.h"

struct grid_info {
    char *input;
    size_t oob;
    size_t length;
    size_t count;
};

struct vec {
    int x;
    int y;
};

static
bool check_word_in_cells(
    struct grid_info *grid, int pos, char const *s, struct vec *move)
{
    if (grid->input[pos] != *s)
        return false;
    if (*++s == '\0')
        return true;
    pos += (move->y * grid->length) + move->x;
    return (pos > 0 && pos < (int)grid->oob)
        && check_word_in_cells(grid, pos, s, move);
}

static
bool check_for_x_shaped_mas(struct grid_info *grid, int pos)
{
    int chks[] = {
        pos - (grid->length + 1),
        pos - (grid->length - 1),
        pos + (grid->length - 1),
        pos + (grid->length + 1)
    };
    char buff[countof(chks)];

    if (grid->input[pos] != 'A')
        return false;
    if (pos < (int)grid->length || pos >= (int)(grid->oob - grid->length))
        return false;

    for (size_t i = 0; i < countof(chks); i++)
        buff[i] = grid->input[chks[i]];
    return (
        !strncmp("MSMS", buff, sizeof buff)
        || !strncmp("MMSS", buff, sizeof buff)
        || !strncmp("SMSM", buff, sizeof buff)
        || !strncmp("SSMM", buff, sizeof buff)
    );
}

static
void count_xmax_in_grid(char *input)
{
    int counts[2] = { 0 };
    struct vec move;
    struct grid_info g = {
        .input = input,
        .length = strcspn(input, "\n") + 1,
        .oob = strlen(input),
    };

    for (size_t pos = 0; pos < g.oob; pos++) {
        if (input[pos] == '\n')
            continue;
        for (move.y = -1; move.y < 2; move.y++)
            for (move.x = -1; move.x < 2; move.x++)
                if (move.x | move.y)
                    counts[0] += check_word_in_cells(&g, pos, "XMAS", &move);

        if (check_for_x_shaped_mas(&g, pos))
            counts[1]++;
    }
    printf("Part 1: %d\n", counts[0]);
    printf("Part 2: %d\n", counts[1]);
}

int main(void)
{
    char *input = NULL;
    int status = EXIT_FAILURE;

    if (!read_file("input", &input))
        goto stop;

    count_xmax_in_grid(input);
    status = EXIT_SUCCESS;
stop:
    return status;
}
