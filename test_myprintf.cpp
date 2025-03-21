#include <stdio.h>

extern "C" void _my_print(const char* buffer, ...);

int main()
{
char c = 'T';
char string1[11] = "wiwiwiwiwi";
char string2[10] = "#$%^*ghFG";

printf("SSSS%c om%d | %x %sg hihi%%h%sih\n", c, 91, 1234354, string1, string2);
_my_print("hello%c om%d | %x %sg hihi%%h%sih %d %d\n", c, 9, 34, string1, string2, 9, 2);
return 0;
}

