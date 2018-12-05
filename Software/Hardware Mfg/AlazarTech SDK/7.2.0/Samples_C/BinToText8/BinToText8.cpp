// BinToText8.cpp : Defines the entry point for the console application.
//

#include "StdAfx.h"

int main(int argc, char *argv[])
{
    // Convert 8-bit binary file to text

    if (argc != 2)
    {
        printf("Usage: BinToText8 <file.bin>\n");
        return 1;
    }

    FILE *fp = fopen(argv[1], "rb");
    if (fp == NULL)
    {
        printf("Error: Open %s failed -- %d\n", argv[1], GetLastError());
        return 1;
    }

    bool success = true;

    for (;;)
    {
        unsigned char value;
        if (fread(&value, sizeof(unsigned char), 1, fp) != (size_t)1)
        {
            if (!feof(fp))
            {
                printf("Error: fread failed -- %d\n", GetLastError());
                success = false;
            }
            break;
        }

        printf("%u\n", value);
    }

    fclose(fp);

    if (!success)
        return 1;

    return 0;
}
