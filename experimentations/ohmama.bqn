#!/usr/bin/env bqn

# I wanted to use getline (cbqn specific)
# https://github.com/dzaima/CBQN/blob/develop/docs/system.md#getline
# > note for later: getline marks eof by returning @
# > this is not in the docs I just asked dzaima (the maintainer)

# that said, to spare myself from erroring on weird filenames,
# it's probably best if I do something like
# find <dir> -type f -name '*.[ch]' -print0 | ./script.bqn
# instead of relying on newlines to always work
#
# and cbqn doesn't have a getdelim
# I could roll a getdelim myself and rely on find -print0
# or I could roll a find function myself
# 
# rolling a find function myself resulted in a rather slow function
# time to do a getdelim instead
# from `man getdelim`
# viewable online at: https://www.man7.org/linux/man-pages/man3/getline.3.html
# here's the signature for getdelim
# 
# ssize_t getdelim(char **restrict lineptr,
#                  size_t *restrict n,
#                  int delim,
#                  FILE *restrict stream);
# 
# https://mlochbaum.github.io/BQN/spec/system.html
# https://mlochbaum.github.io/BQN/doc/ffi.html
# https://github.com/dzaima/CBQN/blob/develop/docs/system.md

# an initial attempt was
# stdin ← @ •foreign.Value "*"‿"stdin"
# gd    ← @ •FFI "isize"‿"getdelim"‿"**u8"‿"&usize"‿"i32"‿"*"

⟨ex⇐exists, ty⇐type, ls⇐list, at⇐at⟩ ← •file
{
    # compile wrapper
    # this immediate block will
    # - check if delim.so already exists
    # - if it doesn't, compile our wrapper into delim.so

    # wrapper included as a string in this bqn file
    # to make it slightly easier to port around
    src ← "
        #include <stdio.h>
        #include <stdint.h>
        #include <stddef.h>
        #include <sys/types.h>
        
        #define MAX_FILELEN (2048)
        char readbuf[MAX_FILELEN];
        ssize_t get_thing(void) {
            return getdelim((char**)&readbuf, NULL, 0, stdin);
        }
    "
    cmd ← ⟨"clang",
           "-O2",
           "-x", "c",
           "-shared", "-fPIC",
           "-o", "delim.so",
           "-Wall", "-Wextra", "-Wpedantic",
           "-",
           ⟩

    { 𝕊@ : ¬ Ex "delim.so" ? •Show { stdin ⇐ src } •Sh cmd ;
      𝕊@ : @ } @
}
gd   ← "delim.so" •FFI "isize"‿"get_thing"
GetDelim ← { 𝕊:
    (0≥Gd@)◶@‿("c8" •foreign.Value "readbuf")
}

readbuf ← "c8" •foreign.Pointer "readbuf"
n ← Gd@
n≥0?@‿readbuf.Read n

#GetDelim
