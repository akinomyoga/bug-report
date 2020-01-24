#include <sys/select.h>
#include <unistd.h>

// Taken from from bash-5.0.11/lib/sh/input_avail.c
int input_avail(int fd) {
  if (fd < 0) return -1;

  fd_set readfds, exceptfds;
  FD_ZERO(&readfds);
  FD_ZERO(&exceptfds);
  FD_SET(fd, &readfds);
  FD_SET(fd, &exceptfds);

  struct timeval timeout;
  timeout.tv_sec = 0;
  timeout.tv_usec = 0;

  return 0 < select(fd + 1, &readfds, (fd_set *) NULL, &exceptfds, &timeout);
}

int main() {
  return !input_avail(0);
}
