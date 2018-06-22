// copyright 2018  Wu, Xingbo

// Build:
// > gcc -DSUBMIT=123.c -o submit submit.c

// Configure:
// > cp submit /usr/local/bin/submit1
// > chmod +s /usr/local/bin/submit1

// Usage:
// > submit1 # as a non-root user, 123.c will be copied to /root/stu with a timestamp

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>

#define BUF_SZ ((1024))
// https://gcc.gnu.org/onlinedocs/gcc-4.8.5/cpp/Stringification.html
#define str1(s) str2(s)
#define str2(s) #s

  int
main(int argc, char ** argv)
{
  FILE * fin = fopen(str1(SUBMIT), "r");
  if (fin == NULL) {
    printf(str1(SUBMIT) " not found\n");
    exit(0);
  }
  char user[BUF_SZ];
  getlogin_r(user, BUF_SZ);
  time_t timer;
  char buffer[26];
  struct tm* tm_info;

  time(&timer);
  tm_info = localtime(&timer);

  strftime(buffer, 26, "%Y-%m-%d-%H-%M-%S", tm_info);
  char fn[BUF_SZ];
  sprintf(fn, "/root/stu/%s-%s-%s", str1(SUBMIT), user, buffer);
  printf("%s\n", fn);
  FILE * fout = fopen(fn, "w");
  char bin[BUF_SZ];
  size_t x;
  while ((x = fread(bin, 1, BUF_SZ, fin)) != 0) {
    fwrite(bin, 1, x, fout);
  }
  fclose(fin);
  fclose(fout);
  exit(0);
}
