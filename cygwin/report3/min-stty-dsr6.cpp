#include <unistd.h>
#include <termios.h>
#include <fcntl.h>

int main() {
  struct termios oldTermios;
  tcgetattr(STDIN_FILENO, &oldTermios);

  // stty -icanon
  struct termios termios = oldTermios;
  termios.c_lflag &= ~(ECHO | ICANON | IEXTEN | ISIG);
  termios.c_iflag &= ~(BRKINT | ICRNL | INPCK | ISTRIP | IXON);
  termios.c_cflag &= ~(CSIZE | PARENB);
  termios.c_cflag |= CS8;
  termios.c_oflag &= ~(OPOST);
  termios.c_cc[VMIN]  = 1;
  termios.c_cc[VTIME] = 0;
  tcsetattr(STDIN_FILENO, TCSAFLUSH, &termios);

  // Request DSR(6)
  write(STDOUT_FILENO, "\033[6n", 4);
  return 0;
}
