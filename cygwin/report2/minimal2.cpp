#include <unistd.h>
#include <termios.h>

int main() {
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
  tcsetattr(STDIN_FILENO, TCSAFLUSH, &termios);

  for (int i = 0; i < 5; i++) {
    char c;
    int const nread = read(STDIN_FILENO, &c, 1);
    write(STDOUT_FILENO, nread > 0 ? "[RECV]" : "[FAIL]", 6);
  }
  tcsetattr(STDIN_FILENO, TCSAFLUSH, &oldTermios);
  write(STDOUT_FILENO, "\n", 1);
  return 0;
}
