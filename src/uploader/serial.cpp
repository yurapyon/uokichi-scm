#include <iostream>
#include <sstream>

#include <string.h>  // strlen

#include <unistd.h>  // close, read, write, usleep
#include <fcntl.h>   // open
#include <termios.h> // termios

#include "serial.hpp"

//

// TODO query programmer for buffer size

//

void ArduinoPort::init(const ArduinoPortSettings &settings) {
    open_serial(settings.filename, settings.baudrate);
    _buf = vector<uint8_t>(settings.max_recv_len + 1, 0);
}

void ArduinoPort::deinit() {
    close(_fd);
}

void ArduinoPort::open_serial(const string &filename, unsigned int baudrate) {
    int fd = open(filename.c_str(), O_RDWR | O_NONBLOCK);

    if (fd == -1) {
        cerr << "couldn't open port: " << filename << endl;
        return;
    }

    struct termios tios;

    if (tcgetattr(fd, &tios)) {
        cerr << "couldn't get terminfo: " << filename << endl;
        close(fd);
        return;
    }

    speed_t spd = B9600;

    switch(baudrate) {
    case 4800:
        spd = B4800;
        break;
    case 9600:
        spd = B9600;
        break;
    case 19200:
        spd = B19200;
        break;
    case 38400:
        spd = B38400;
        break;
    case 57600:
        spd = B57600;
        break;
    case 115200:
        spd = B115200;
        break;
    default:
        break;
    }

    cfsetispeed(&tios, spd);
    cfsetospeed(&tios, spd);

    // 8nX, minimal flow control, raw
    cfmakeraw(&tios);

    // 1 stop bit
    tios.c_cflag &= ~CSTOPB;

    // no flow control
    tios.c_cflag &= ~CRTSCTS;
    tios.c_iflag &= ~(IXOFF | IXANY);

    // turn on read
    tios.c_cflag |= CREAD;

    // wait for one char before returning from a read on this fd
    // note: vtime is in 0.1 secs
    tios.c_cc[VMIN]  = 0;
    tios.c_cc[VTIME] = 0;

    if (tcsetattr(fd, TCSAFLUSH, &tios)) {
        cerr << "couldn't set terminfo: " << filename << endl;
        close(fd);
        return;
    }

    _fd = fd;

    cout << "connected to programmer" << endl
         << "port: " << filename << endl
         << "baudrate: " << baudrate << endl;
}

int ArduinoPort::receive() {
    uint8_t msg_sz = 0;
    ssize_t res;

    while (true) {
        res = read(_fd, &msg_sz, 1);

        if (res > 0) {
            break;
        } else if (res == 0) {
            usleep(50000);
        } else {
            cerr << "read error" << endl;
            return -1;
        }
    }

    uint8_t recv_buf_len = 0;
    uint8_t *recv_buf = _buf.data();

    while (true) {
        res = read(_fd, recv_buf + recv_buf_len, 1);

        // TODO handle_max_recv_len / _buf.size()

        if (res > 0) {
            recv_buf_len++;
            if (recv_buf_len >= msg_sz) {
                break;
            }
        } else if (res == 0) {
            usleep(50000);
        } else {
            cerr << "read error" << endl;
            return -1;
        }
    }

    recv_buf[recv_buf_len] = 0;

    return msg_sz;
}

void ArduinoPort::transmit(const uint8_t *buf, unsigned int sz) {
    write(_fd, &sz, 1);
    write(_fd, buf, sz);
}

void ArduinoPort::transmit_string(const string &str) {
    transmit((const uint8_t *)str.c_str(), str.length());
}

bool ArduinoPort::wait_for_done() {
    while (true) {
        receive();
        string responce((const char *)_buf.data());
        if (!responce.compare(0, 5, "done:")) {
            if (verbose) {
                cout << "pDone: " << responce.substr(5) << endl;
            }
            return true;
        } else if (!responce.compare(0, 5, "fail:")) {
            if (verbose) {
                cerr << "pFail: " << responce.substr(5) << endl;
            }
            return false;
        } else if (!responce.compare(0, 4, "msg:")) {
            if (verbose) {
                cout << "pMsg: " << responce.substr(4) << endl;
            }
        } else if (!responce.compare(0, 5, "warn:")) {
            if (verbose) {
                cerr << "pWarning: " << responce.substr(5) << endl;
            }
        } else {
            cerr << "strange message: " << responce << endl;
            return false;
        }
    }
}

//

Programmer::Programmer() {
    // TODO handle errors if cant open device

    ArduinoPortSettings aps;
    _ap.init(aps);
    _ap.wait_for_done();
}

Programmer::~Programmer() {
    _ap.deinit();
}

bool Programmer::set_chip(const string &str) {
    if (str == "atmega328p") {
        _ap.transmit_string("set:chip:atmega328p");
        return _ap.wait_for_done();
    } else {
        cerr << "chip not supported: " << str << endl;
        return false;
    }
}

bool Programmer::send_hex_file(const string &hex_file) {
    _ap.transmit_string("prog:begin");
    if(!_ap.wait_for_done()) {
        return false;
    }

    _ap.transmit_string("prog:send_hex");
    if(!_ap.wait_for_done()) {
        return false;
    }

    istringstream iss(hex_file);
    string line;
    while (getline(iss, line)) {
        _ap.transmit_string(line);
        if(!_ap.wait_for_done()) {
            return false;
        }
    }

    _ap.transmit_string("prog:end");
    if(!_ap.wait_for_done()) {
        return false;
    }

    return true;
}

//

/*
int main() {
    string hex_file =
        ":10000000940c00340000000000000000000000001c\n"
        ":1000080000000000000000000000000000000000e8\n"
        ":1000100000000000000000000000000000000000e0\n"
        ":1000180000000000000000000000000000000000d8\n"
        ":1000200000000000000000000000000000000000d0\n"
        ":1000280000000000000000000000000000000000c8\n"
        ":080030000000000000000000c8\n"
        ":0a0034009a3d9a45c0009845cffca4\n"
        ":00000001ff\n";
    Programmer p;

    cout << "starting transmission" << endl;

    p.set_chip("atmega328p");
    cout << "set chip" << endl;
    p.send_hex_file(hex_file);
    cout << "sent hex" << endl;

    return 0;
}
*/
