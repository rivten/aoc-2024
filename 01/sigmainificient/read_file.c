#include <fcntl.h>
#include <stdbool.h>
#include <stdlib.h>
#include <unistd.h>

#include <sys/stat.h>

#include "helpers.h"

static inline
bool read_fd_buffer(int fd, char **store, ssize_t size)
{
    *store = malloc((size + 1) * sizeof **store);

    if (*store == NULL)
        return fatal("Allocation Failure."), false;
    if (read(fd, *store, size) != size)
        return fatal("Couldn't read the file content."), false;
    (*store)[size] = '\0';
    return true;
}

bool read_file(char const *filepath, char **store)
{
    bool succeed = false;
    int fd = open(filepath, O_RDWR);
    struct stat file_info;

    if (fd < 0)
        fatal("Failed to open the input file.");
    else if (fstat(fd, &file_info) < 0)
        fatal("Failed to retrieve file information.");
    else
        succeed = read_fd_buffer(fd, store, file_info.st_size);
    return close(fd), succeed;
}
