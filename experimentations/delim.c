#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <sys/types.h>

#define MAX_FILELEN (2048)
char readbuf[MAX_FILELEN];
ssize_t get_thing(void) {
    return getdelim((char**)&readbuf, NULL, 0, stdin);
}
