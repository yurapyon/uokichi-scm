#include <Arduino.h>

//

#define P_LED 13

bool light_on = false;

void toggle_light() {
    if (light_on) {
        digitalWrite(P_LED, LOW);
        light_on = false;
    } else {
        digitalWrite(P_LED, HIGH);
        light_on = true;
    }
}

//

struct PCPortSettings {
    unsigned int baudrate;

    PCPortSettings(unsigned int baudrate = 19200)
    : baudrate(baudrate) {
    }
};

#define PCPORT_MAX_RECV_LEN 256

class PCPort {
public:
    void init(const PCPortSettings &);
    void deinit();

    int receive();
    void transmit(const uint8_t *buf, unsigned int sz);

    void send_ok();

    uint8_t *buffer() {
        return _buf;
    }

private:
    uint8_t _buf[PCPORT_MAX_RECV_LEN + 1];
};

void PCPort::init(const PCPortSettings &settings) {
    Serial.begin(settings.baudrate);
    memset(_buf, 0, PCPORT_MAX_RECV_LEN + 1);
}

void PCPort::deinit() {
    Serial.end();
}

int PCPort::receive() {
    uint8_t msg_sz;

    while (true) {
        if (Serial.available() > 0) {
            msg_sz = Serial.read();
            break;
        }

        delay(1);
    }

    uint8_t recv_buf_len = 0;

    while (true) {
        // TODO handle MAX_RECV_LEN

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
    Serial.flush();
    Serial.write(buf, sz);
    Serial.flush();
}

//

class StringPort {
public:
    void init();
    void deinit();

    void transmit_string(const String &);
    String receive();

    void send_ok();
    void send_error(const String &);

private:
    PCPort _pcp;
};

void StringPort::init() {
    PCPortSettings pcps;
    _pcp.init(pcps);
}

void StringPort::deinit() {
    _pcp.deinit();
}

void StringPort::transmit_string(const String &str) {
    _pcp.transmit((const uint8_t *)str.c_str(), str.length());
}

String StringPort::receive() {
    _pcp.receive();
    return String((const char *)_pcp.buffer());
}

void StringPort::send_ok() {
    transmit_string("ok");
}

void StringPort::send_error(const String &msg) {
    String err("err:");
    err.concat(msg);
    transmit_string(err);
}

StringPort sp;

//

enum ChipType {
    CHIP_ATMEGA_328P
} chip_type;

void set_chip(const String &name) {
    if (name == "atmega328p") {
        chip_type = CHIP_ATMEGA_328P;
        toggle_light();
    }
}

//

void setup() {
    pinMode(P_LED, OUTPUT);
    digitalWrite(P_LED, LOW);

    sp.init();
}

void loop() {
    String str = sp.receive();

    if (str.startsWith("set:")) {
        str = str.substring(4);
        if (str.startsWith("chip:")) {
            set_chip(str.substring(5));
            sp.send_ok();
        }
    }

    delay(25);
}
