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

/*#include <glob/strmatch.h>*/
int strmatch(char *pattern, char *string, int flags);
#define FNM_PATHNAME    (1 << 0)
#define FNM_NOESCAPE    (1 << 1)
#define FNM_PERIOD      (1 << 2)
#define FNM_LEADING_DIR (1 << 3)
#define FNM_CASEFOLD    (1 << 4)
#define FNM_EXTMATCH    (1 << 5)
#define FNM_FIRSTCHAR   (1 << 6)
#define FNM_DOTDOT      (1 << 7)
#define FNM_MODE_EXACT          (0 << 16)
#define FNM_MODE_PREFIX_MODEST  (1 << 16)
#define FNM_MODE_PREFIX_GREEDY  (2 << 16)
#define FNM_MODE_SUFFIX_MODEST  (3 << 16)
#define FNM_MODE_SUFFIX_GREEDY  (4 << 16)
#define FNM_MODE_MIDDLE         (5 << 16)
#define FNM_MODE_MIDDLE_ALL     (6 << 16)

static int strmatch_builtin(struct word_list* list) {
  char *str, *pat;
  int opt, flags, mode;

  flags = FNM_EXTMATCH;
  mode = FNM_MODE_EXACT;

  reset_internal_getopt ();
  while ((opt = internal_getopt (list, "/.edilSsPpMm")) != -1)
    {
      switch (opt)
        {
        case '/':
          flags |= FNM_PATHNAME;
          break;
        case '.':
          flags |= FNM_PERIOD;
          break;
        case 'e':
          flags |= FNM_NOESCAPE;
          break;
        case 'd':
          flags |= FNM_DOTDOT;
          break;
        case 'i':
          flags |= FNM_CASEFOLD;
          break;
        case 'l':
          flags |= FNM_LEADING_DIR;
          break;

        case 'S':
          mode = FNM_MODE_SUFFIX_GREEDY;
          break;
        case 's':
          mode = FNM_MODE_SUFFIX_MODEST;
          break;
        case 'P':
          mode = FNM_MODE_PREFIX_GREEDY;
          break;
        case 'p':
          mode = FNM_MODE_PREFIX_MODEST;
          break;
        case 'M':
          mode = FNM_MODE_MIDDLE_ALL;
          break;
        case 'm':
          mode = FNM_MODE_MIDDLE;
          break;

        case GETOPT_HELP:
          builtin_help ();
          return EX_USAGE;
        default:
          builtin_usage ();
          return EX_USAGE;
        }
    }
  list = loptend;

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

  if (list && list->word && list->word->word)
    {
      builtin_usage ();
      return EX_USAGE;
    }

  return strmatch (pat, str, flags | mode);
}
static const char* strmatch_doc[] = { "This is a builtin to test the behavior of strmatch", 0 };
struct builtin strmatch_struct = { "strmatch", strmatch_builtin, BUILTIN_ENABLED, strmatch_doc, "strmatch [-SsPpMm] [-/.edil] pattern string", 0, };
