#include <stdio.h>

extern "C" void _my_print(const char* buffer, ...);

int main()
{
_my_print("hello omg hihihih", 10);
return 0;
}

