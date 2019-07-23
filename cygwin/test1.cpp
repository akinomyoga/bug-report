#include <cstdlib>
#include <cstdio>

int main() {
  std::printf("TERM=%s\n", std::getenv("TERM"));
  std::printf("\eM\e[B");
  std::printf("\e[2 qhello");
  std::printf("input a number: ");
  std::fflush(stdout);

  int a = 0;
  std::scanf("%d", &a);
  return 0;
}
