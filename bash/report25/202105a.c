#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
int main() {
  int fd = open("202105a.txt", O_RDWR | O_APPEND);
  char c;
  int r;

  r = lseek(fd, -1, SEEK_CUR);
  printf("lseek(0, CUR): %d\n", r);

  r = read(fd, &c, 1);
  printf("read(1): %d, c = %d\n", r, (unsigned char) c);

  r = write(fd, "O", 1);
  printf("write(\"O\", 1): %d\n", r);
  close(fd);
}
