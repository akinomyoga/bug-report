#include <unistd.h>
// #include <termios.h>
#include <fcntl.h>
#include <ctype.h>

#include <stdio.h>
#include <stdlib.h>

#include <string.h>

// Taken from from bash-5.0.11/lib/sh/input_avail.c
// $ read -t 0
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

void print_char(char c) {
  char buff[4];
  int i = 0;
  if (isgraph(c)) {
    buff[i++] = c;
    buff[i++] = ' ';
  } else if (c < 0x20 || c == 0x7F) {
    buff[i++] = '^';
    buff[i++] = c == 0x7F ? '?' : c + 0x40;
    buff[i++] = ' ';
  } else {
    buff[i++] = '?';
    buff[i++] = '?';
    buff[i++] = '?';
    buff[i++] = ' ';
  }
  write(STDOUT_FILENO, buff, i);
}

int main(int argc, char** argv) {
  // Request DSR(6)
  write(STDOUT_FILENO, "\033[6n", 4);

  // read -t 0
  if (argc == 2 && strchr(argv[1], 't'))
    input_avail(STDIN_FILENO);

  // read line
  for (;;) {
    char c;
    ssize_t result = read(STDIN_FILENO, &c, 1);
    if (result != 1) {
      write(STDOUT_FILENO, result == 0 ? "EOF" : "ERR", 4);
      break;
    }

    print_char(c);
    if (c == '\n') break;
  }
  write(STDOUT_FILENO, "\n", 1);
  return 0;
}
