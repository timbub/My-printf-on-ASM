#include <stdio.h>

extern "C" void _my_print(const char* buffer, ...);

int main()
{
char c = 'T';
char string1[11] = "STRING1";
char string2[10] = "STRING2";

printf(   "hello %c om%d | %x %s hihi %% hih %o\n", c, 9, 123456789, string1, 12);

_my_print("hello %c om%d | %x %s hihi %% hih %o\n", c, 9, 123456789, string1, 12);
return 0;
}

