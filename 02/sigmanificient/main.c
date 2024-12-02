#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "helpers.h"

#define ENOUGH_FOR_INPUT 8

static
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

static
bool is_safe_report(int const *nums, size_t length)
{
    bool negative = false;
    int diff;

    if (length < 2)
        return true;
    negative = (nums[1] - nums[0]) < 0;
    for (size_t i = 1; i < length; i++) {
        diff = nums[i] - nums[i - 1];

        if (negative)
            diff = -diff;
        if (diff <= 0 || diff > 3)
            return false;
    }
    return true;
}

static
bool is_safe_report_tolerance(int const *nums, size_t len)
{
    int copy[ENOUGH_FOR_INPUT];

    if (is_safe_report(nums + 1, len - 1) || is_safe_report(nums, len - 1))
        return true;

    for (size_t i = 1; i < len - 1; i++) {
        memcpy(copy, nums, i * sizeof *nums);
        memcpy(&copy[i], &nums[i + 1], (len - i) * sizeof *nums);
        if (is_safe_report(copy, len - 1))
            return true;
    }
    return false;
}

int main(void)
{
    char *input;
    int nums[ENOUGH_FOR_INPUT];
    size_t count;
    size_t safe = 0;
    size_t safe_with_tolerance = 0;

    if (!read_file("input", &input))
        goto stop;

    for (char *line = strtok(input, "\n");
        line != NULL; line = strtok(NULL, "\n")
    ) {
        count = parse_report_values(line, nums);
        safe += is_safe_report(nums, count);
        safe_with_tolerance += is_safe_report_tolerance(nums, count);
    }

    printf("Part 1: %zu\n", safe);
    printf("Part 2: %zu\n", safe_with_tolerance);

stop:
    return EXIT_SUCCESS;
}
