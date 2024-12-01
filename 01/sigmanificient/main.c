#include <fcntl.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

#include "helpers.h"

struct lists {
    int *left;
    int *right;
    size_t nmemb;
};

static
bool parse_lists(char const *file_content, struct lists *parsed)
{
    int *lists;

    for (char const *s = file_content; *s != '\0'; s++)
        parsed->nmemb += *s == '\n';

    lists = malloc((2L * parsed->nmemb) * sizeof *lists);
    if (lists == NULL)
        return fatal("Allocation Failure."), false;

    parsed->left = lists;
    parsed->right = &lists[parsed->nmemb];

    for (char const *s = file_content; *s != '\0'; ) {
#pragma GCC diagnostic push /* strtol ABI uses char ** :< */
#pragma GCC diagnostic ignored "-Wincompatible-pointer-types"
        *parsed->left++ = (int)strtol(s, &s, 10);
        s += strspn(s, " ");
        *parsed->right++ = (int)strtol(s, &s, 10);
#pragma GCC diagnostic pop

        s += strspn(s, "\n");
    }

    parsed->left -= parsed->nmemb;
    parsed->right -= parsed->nmemb;
    return true;
}

static
int compare_ints(const int *a, const int *b)
{
    return *a - *b;
}

static
int compute_summed_difference(struct lists *lsts)
{
    int sum = 0;
    int diff = 0;

    for (size_t i = 0; i < lsts->nmemb; i++) {
       diff = lsts->left[i] - lsts->right[i];
       if (diff < 0)
           diff = -diff;
       sum += diff;
    }
    return sum;
}

static
int compute_similarity(struct lists *lsts)
{
    int total = 0;
    int count;

    for (size_t i = 0; i < lsts->nmemb; i++) {
        count = 0;
        for (size_t j = 0; j < lsts->nmemb; j++)
            count += lsts->right[j] == lsts->left[i];
        total += lsts->left[i] * count;
    }
    return total;
}

int main(void)
{
    char *input;
    struct lists lsts = { 0 };
    int status = EXIT_FAILURE;

    if (!read_file("input", &input) || !parse_lists(input, &lsts))
        goto stop;

    qsort(lsts.left, lsts.nmemb, sizeof *lsts.left, comparator(compare_ints));
    qsort(lsts.right, lsts.nmemb, sizeof *lsts.left, comparator(compare_ints));

    printf("part 1: %d\n", compute_summed_difference(&lsts));
    printf("part 2: %d\n", compute_similarity(&lsts));
    status = EXIT_SUCCESS;

stop:
    free(lsts.left);
    free(input);
    return status;
}
