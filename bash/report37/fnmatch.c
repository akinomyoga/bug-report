#include <fnmatch.h>
#include <stdlib.h>
#include <stdio.h>

int main(int argc, char **argv) {
  if (2 >= argc) {
    fprintf(stderr, "usage: fnmatch string pattern\n");
    exit(2);
  }

  int flags = FNM_PATHNAME | FNM_PERIOD;
  if (fnmatch(argv[2], argv[1], flags) == 0)
    return 0;
  return 1;
}
