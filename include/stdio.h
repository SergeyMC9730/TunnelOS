#pragma once

#include "./main.h"

void puts(char *str, uint32_t color);
void putc(char c, uint32_t color);
void printf(uint32_t color, const char *fmt, ...);

extern int ty, tx, kx;

char *itoa(int num, char *buffer, int base);
char itoh(int num, bool upper);
char itoc(int num);
char* strrev(char* src);