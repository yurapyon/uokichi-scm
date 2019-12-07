#include <iostream>
#include <string>
#include <vector>

#include <unistd.h>  // close, read, write, usleep
#include <fcntl.h>   // open
#include <termios.h> // termios

using namespace std;

// ArduinoPort

struct ArduinoPortSettings {
    const string &filename;
    unsigned int baudrate;
    unsigned int buf_sz;

    ArduinoPortSettings(const string &filename = "/dev/ttyACM0",
                        unsigned int baudrate = 19200,
                        unsigned int buf_sz = 256)
    : filename(filename)
    , baudrate(baudrate)
    , buf_sz(buf_sz) {
    }
};

class ArduinoPort {
public:
    ArduinoPort(const ArduinoPortSettings &);
    ~ArduinoPort();

    int receive();
    void transmit(const uint8_t *buf, unsigned int sz);

    uint8_t *buffer() {
        return _buf.data();
    }

private:
    int _fd;
    vector<uint8_t> _buf;

    void open_serial(const string &filename, unsigned int baudrate);
};

ArduinoPort::ArduinoPort(const ArduinoPortSettings &settings) {
    open_serial(settings.filename, settings.baudrate);
    _buf = vector<uint8_t>(settings.buf_sz, 0);
}

ArduinoPort::~ArduinoPort() {
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

    speed_t spd;
    switch(baudrate) {
    case 4800:   spd = B4800;   break;
    case 9600:   spd = B9600;   break;
    case 19200:  spd = B19200;  break;
    case 38400:  spd = B38400;  break;
    case 57600:  spd = B57600;  break;
    case 115200: spd = B115200; break;
    default:     spd = B9600;   break;
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
            fprintf(stderr, "read error\n");
            return -1;
        }
    }

    uint8_t recv_buf_len = 0;
    uint8_t *recv_buf = _buf.data();

    while (true) {
        res = read(_fd, recv_buf + recv_buf_len, 1);

        if (res > 0) {
            recv_buf_len++;
            if (recv_buf_len >= msg_sz) {
                break;
            }

            // TODO error on out of bounds of _buf

        } else if (res == 0) {
            usleep(50000);
        } else {
            fprintf(stderr, "read error\n");
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

//

//

int main() {
    ArduinoPortSettings aps;
    ArduinoPort ap(aps);

    int len = ap.receive();
    cout << "len: " << len << " msg: " << (const char *)ap.buffer() << endl;

    return 0;
}
