#include <unistd.h>
#include <termios.h>
#include <fcntl.h>
#include <ctype.h>

#include <stdio.h>
#include <stdlib.h>

#include <time.h> /* for nanosleep */
#include <errno.h>

#include <string.h>

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

void msleep(int msec) {
  struct timespec req, rem;
  req.tv_sec = msec / 1000;
  req.tv_nsec = msec % 1000 * 1000000;
  while (nanosleep(&req, &rem) == -1 && errno == EINTR)
    req = rem;
}

// Redirection
// $ : < /dev/null
void redirect() {
  int fd = open("/dev/null", O_RDONLY);
  int fd_save = fcntl(STDIN_FILENO, F_DUPFD, 10);
  dup2(fd, STDIN_FILENO);
  dup2(fd_save, STDIN_FILENO);
  close(fd_save);
  close(fd);
}

int main(int argc, char** argv) {
  struct termios oldTermios;
  tcgetattr(STDIN_FILENO, &oldTermios);

  struct termios termios = oldTermios;
  termios.c_lflag &= ~(ECHO | ICANON | IEXTEN | ISIG);
  termios.c_iflag &= ~(BRKINT | ICRNL | INPCK | ISTRIP | IXON);
  termios.c_cflag &= ~(CSIZE | PARENB);
  termios.c_cflag |= CS8;
  termios.c_oflag &= ~(OPOST);
  termios.c_cc[VMIN]  = 1;
  termios.c_cc[VTIME] = 0;
  //tcsetattr(STDIN_FILENO, TCSANOW, &termios);
  tcsetattr(STDIN_FILENO, TCSAFLUSH, &termios);

  // Request DSR(6)
  write(STDOUT_FILENO, "\033[6n", 4);

  // read -t 0
  //msleep(100);
  if (argc != 2 || !strchr(argv[1], 'T'))
    input_avail(STDIN_FILENO);

  //system(": < /dev/null; read || echo EOF");

  // : < /dev/null
  if (argc != 2 || !strchr(argv[1], 'R'))
    redirect();

  // Read DSR(6) Response
  for (;;) {
    char c;
    ssize_t result = read(STDIN_FILENO, &c, 1);
    if (result != 1) {
      write(STDOUT_FILENO, result == 0 ? "EOF" : "ERR", 4);
      break;
    }
    write(STDOUT_FILENO, "CHR ", 4);
    if (isalpha(c)) break;
  }

  tcsetattr(STDIN_FILENO, TCSAFLUSH, &oldTermios);
  write(STDOUT_FILENO, "\n", 1);
  return 0;
}
