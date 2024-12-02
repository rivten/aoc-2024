#ifndef HELPERS_H
    #define HELPERS_H

    #define lengthof(msg) (sizeof (msg) - 1)
    #define fatal(msg) write(STDERR_FILENO, (msg), lengthof(msg))

    #define comparator(pfunc) (int (*)(void const *, void const *))(pfunc)

bool read_file(char const *filepath, char **store);

#endif
