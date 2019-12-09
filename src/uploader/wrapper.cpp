#include "serial.hpp"

#ifdef __cplusplus
extern "C" {
#endif

    Programmer *uo_programmer_new() {
        return new Programmer();
    }

    void uo_programmer_delete(Programmer *p) {
        delete p;
    }

    bool uo_programmer_set_chip(Programmer *p, const char *str) {
        return p->set_chip(string(str));
    }

    bool uo_programmer_send_hex_file(Programmer *p, const char *str) {
        return p->send_hex_file(string(str));
    }

#ifdef __cplusplus
}
#endif
