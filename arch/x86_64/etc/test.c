#include "../include/test.h"
#include "../include/serial.h"

unitype_t *__test_univariable = NULL;
void __test_unitest() {
    __serial_write_fmt("[Test] Allocation unitype_t variable with \"siiin\"\n");
    __test_univariable = __uni_create("siiin");
    __serial_write_fmt("[Test] Freeing %x\n", __test_univariable);
    __uni_delete(__test_univariable);
    __serial_write_fmt("[Test] Unitype_t test completed successfully\n");
    return;
}