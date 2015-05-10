#include <stdio.h>

extern void calc_func(int x);

int check(int x);

int check(int x)
{
	if ((x <= 0) || ( x > 31 )) {
		return 0;
	} else {
		return 1;
	}
}

int main(int argc, char** argv)
{
  int x;

  printf("insert number: ");
  scanf("%d", &x);

  calc_func(x);

  return 0;
}
