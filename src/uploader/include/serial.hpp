#ifndef UO_SERIAL_HPP
#define UO_SERIAL_HPP

#include <string>
#include <vector>

using namespace std;

struct ArduinoPortSettings {
    const string &filename;
    unsigned int baudrate;
    unsigned int max_recv_len;

    ArduinoPortSettings(const string &filename = "/dev/ttyACM0",
                        unsigned int baudrate = 19200,
                        unsigned int max_recv_len = 256)
    : filename(filename)
    , baudrate(baudrate)
    , max_recv_len(max_recv_len) {
    }
};

class ArduinoPort {
public:
    void init(const ArduinoPortSettings &);
    void deinit();

    int receive();
    void transmit(const char *buf, unsigned int sz);

    uint8_t *buffer() {
        return _buf.data();
    }

private:
    int _fd;
    vector<uint8_t> _buf;

    void open_serial(const string &filename, unsigned int baudrate);
};

class Programmer {
public:
    Programmer();
    ~Programmer();

    bool set_chip(const string &);
    bool send_hex_file(const string &);

private:
    ArduinoPort _ap;

    void transmit_string(const string &);
    bool check_ok();
};

#endif

