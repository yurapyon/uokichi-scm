#ifndef UO_WRAPPER_HPP
#define UO_WRAPPER_HPP

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

    typedef struct Programmer Programmer;

    Programmer *uo_programmer_new();
    void uo_programmer_delete(Programmer *);

    bool uo_programmer_set_chip(Programmer *, const char *);
    bool uo_programmer_write_hex_file(Programmer *, const char *);

#ifdef __cplusplus
}
#endif

#endif
