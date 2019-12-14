#include <iostream>
#include <stdexcept>

#include "serial.hpp"

using namespace std;

#ifdef __cplusplus
extern "C" {
#endif

    Programmer *uo_programmer_new() {
        try {
            return new Programmer();
        } catch (const runtime_error &e) {
            cerr << e.what() << endl;
            return nullptr;
        }
    }

    void uo_programmer_delete(Programmer *p) {
        delete p;
    }

    bool uo_programmer_set_chip(Programmer *p, const char *str) {
        return p->set_chip(string(str));
    }

    bool uo_programmer_write_hex_file(Programmer *p, const char *str) {
        return p->write_hex_file(string(str));
    }

#ifdef __cplusplus
}
#endif
