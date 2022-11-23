#include <fnmatch.h>

/*#include "../command.h"*/
struct word_desc { char* word; int flags; };
struct word_list { struct word_list* next; struct word_desc* word; };
/*#include "../builtins.h"*/
#define BUILTIN_ENABLED 0x01
struct builtin {
  const char* name;
  int (*function)(struct word_list*);
  int flags;
  const char** long_doc;
  const char* short_doc;
  char* handle;
};
/*#include "../shell.h"*/
#define EX_USAGE 258
/*#include "bashgetopt.h"*/
#define GETOPT_HELP -99
extern struct word_list *loptend;
void reset_internal_getopt(void);
int internal_getopt(struct word_list *, char *);
/*#include "common.h"*/
void builtin_help(void);
void builtin_usage(void);

static int fnmatch_builtin(struct word_list* list) {
  char *str, *pat;
  int flags;

  flags = FNM_EXTMATCH;

  if (list && list->word && list->word->word)
    {
      pat = list->word->word;
      list = list->next;
    }
  else
    {
      builtin_usage ();
      return EX_USAGE;
    }

  if (list && list->word && list->word->word)
    {
      str = list->word->word;
      list = list->next;
    }
  else
    {
      builtin_usage ();
      return EX_USAGE;
    }

  return fnmatch (pat, str, flags);
}
static const char* fnmatch_doc[] = { "This is a builtin to test the behavior of fnmatch", 0 };
struct builtin fnmatch_struct = { "fnmatch", fnmatch_builtin, BUILTIN_ENABLED, fnmatch_doc, "fnmatch pattern string", 0, };

#if 0
#include <stdlib.h>
#include <stdio.h>

int main(int argc, char **argv) {
  if (2 >= argc) {
    fprintf(stderr, "usage: fnmatch string pattern\n");
    exit(2);
  }

  int flags = FNM_PATHNAME | FNM_PERIOD | FNM_EXTMATCH;
  if (fnmatch(argv[2], argv[1], flags) == 0)
    return 0;
  return 1;
}
#endif
