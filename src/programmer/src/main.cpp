#include <Arduino.h>

//

struct PCPortSettings {
    unsigned int baudrate;

    PCPortSettings(unsigned int baudrate = 19200)
    : baudrate(baudrate) {
    }
};

#define PCPORT_BUF_SZ 256

class PCPort {
public:
    void init(const PCPortSettings &);
    void deinit();

    int receive();
    void transmit(const uint8_t *buf, unsigned int sz);

    uint8_t *buffer() {
        return _buf;
    }

private:
    uint8_t _buf[PCPORT_BUF_SZ];
};

void PCPort::init(const PCPortSettings &settings) {
    Serial.begin(settings.baudrate);
    memset(_buf, 0, PCPORT_BUF_SZ);
}

void PCPort::deinit() {
    Serial.end();
}

int PCPort::receive() {
    uint8_t msg_sz;

    while(true) {
        if (Serial.available() > 0) {
            msg_sz = Serial.read();
            break;
        }

        delay(1);
    }

    uint8_t recv_buf_len = 0;

    while(true) {
        // TODO handle out of bounds _buf
        if (Serial.available() > 0) {
            _buf[recv_buf_len] = Serial.read();
            recv_buf_len++;
            if (recv_buf_len >= msg_sz) {
                break;
            }
        }

        delay(1);
    }

    _buf[recv_buf_len] = 0;

    return msg_sz;
}

void PCPort::transmit(const uint8_t *buf, unsigned int sz) {
    Serial.write(sz);
    Serial.write(buf, sz);
    Serial.flush();
}

//

PCPort pcp;

void setup() {
    PCPortSettings pcps;
    pcp.init(pcps);

    pcp.transmit("0123456789abcdef0123456789abcdef0123456789abcdef", 48);
}

void loop() {
    delay(500);
}
