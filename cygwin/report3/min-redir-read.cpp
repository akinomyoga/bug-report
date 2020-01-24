#include <unistd.h>
#include <termios.h>
#include <fcntl.h>
#include <ctype.h>

void redirect() {
  // Redirection
  int fd = open("/dev/null", O_RDONLY);
  int fd_save = 10;
  dup2(STDIN_FILENO, fd_save);
  dup2(fd, STDIN_FILENO);
  dup2(fd_save, STDIN_FILENO);

  // int fd_save = fcntl(STDIN_FILENO, F_DUPFD, 10);
  // close(STDIN_FILENO);
  // fcntl(fd_save, F_SETFD, FD_CLOEXEC);
  // dup2(fd, STDIN_FILENO);
  // close(fd);
  // dup2(fd_save, STDIN_FILENO);
  // close(fd_save);
}

int main() {
  // : < /dev/null
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

  return 0;
}
