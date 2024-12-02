#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../../01/sigmanificient/helpers.h"

size_t parse_report_values(char *line, int *nums)
{
    size_t count = 0;

    for (; *line != '\0'; ) {
        nums[count] = strtol(line, &line, 10);
        while (*line == ' ') line++;
        count++;
    }
    return count;
}

bool is_safe_report(int const *nums, size_t length)
{
    bool negative = false;
    int diff;

    if (length < 2)
        return true;

    negative = (nums[1] - nums[0]) < 0;
    for (size_t i = 0; i < length - 1; i++) {
        diff = nums[i + 1] - nums[i];

        if (negative)
            diff = -diff;
        if (diff < 1 || diff > 3)
            return false;
    }
    return true;
}

int main(void)
{
    char *input;
    int nums[64];
    size_t count;
    size_t safe = 0;

    if (!read_file("input", &input))
        goto stop;

    for (char *line = strtok(input, "\n");
        line != NULL; line = strtok(NULL, "\n")
    ) {
        count = parse_report_values(line, nums);
        safe += is_safe_report(nums, count);
    }

    printf("Part 1: %zu\n", safe);

stop:
    return EXIT_SUCCESS;
}
