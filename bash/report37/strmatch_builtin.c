#define BUILTIN_ENABLED 0x01
struct word_desc { char* word; int flags; };
struct word_list { struct word_list* next; struct word_desc* word; };
struct builtin {
  const char* name;
  int (*function)(struct word_list*);
  int flags;
  const char** long_doc;
  const char* short_doc;
  char* handle;
};

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

static int strmatch_builtin(struct word_list* list) {
  char *str, *pat;
  if (!list || !list->word) return 2;
  str = list->word->word;
  if (!list->next || !list->next->word) return 2;
  pat = list->next->word->word;

  if (strmatch (pat, str, FNM_PATHNAME | FNM_PERIOD | FNM_EXTMATCH) == 0)
    return 0;
  return 1;
}
static const char* strmatch_doc[] = { "This is a builtin to test the behavior of strmatch", 0 };
struct builtin strmatch_struct = { "strmatch", strmatch_builtin, BUILTIN_ENABLED, strmatch_doc, "strmatch string pattern", 0, };
