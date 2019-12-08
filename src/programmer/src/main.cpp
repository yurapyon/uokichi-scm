#include <Arduino.h>
#include <SPI.h>

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

// SPI

#define P_MOSI  11
#define P_MISO  12
#define P_SCK   13
#define P_RESET 8

uint8_t spi_transfer4(uint8_t a1, uint8_t a2, uint8_t a3, uint8_t a4) {
    uint8_t ret;

    SPI.transfer(a1);
    SPI.transfer(a2);
    SPI.transfer(a3);
    ret = SPI.transfer(a4);
    return ret;
}

uint8_t spi_transfer3(uint8_t a1, uint8_t a2, uint8_t a3, uint8_t a4) {
    uint8_t ret;

    SPI.transfer(a1);
    SPI.transfer(a2);
    ret = SPI.transfer(a3);
    SPI.transfer(a4);
    return ret;
}

uint8_t spi_transfer4(uint32_t val) {
    return spi_transfer4((val >> 24) & 0xff
                       , (val >> 16) & 0xff
                       , (val >>  8) & 0xff
                       , val & 0xff);
}

uint8_t spi_transfer3(uint32_t val) {
    return spi_transfer3((val >> 24) & 0xff
                       , (val >> 16) & 0xff
                       , (val >>  8) & 0xff
                       , val & 0xff);
}

void spi_init_pins() {
    pinMode(P_MOSI, OUTPUT);
    pinMode(P_MISO, INPUT);
    pinMode(P_SCK, OUTPUT);
    pinMode(P_RESET, OUTPUT);
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
    void send_ok(const String &);
    void send_error(const String &);
    void send_warning(const String &);

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

void StringPort::send_ok(const String &msg) {
    String str("ok:");
    str.concat(msg);
    transmit_string(str);
}

void StringPort::send_error(const String &msg) {
    String str("err:");
    str.concat(msg);
    transmit_string(str);
}

void StringPort::send_warning(const String &msg) {
    String str("warn:");
    str.concat(msg);
    transmit_string(str);
}

//

enum ChipType {
    CHIP_NONE ,
    CHIP_ATMEGA_328P
};

class Programmer {
public:
    Programmer(StringPort &sp)
    : _sp(sp) {
        _chip_type = CHIP_NONE;
    }

    void set_chip(const String &name) {
        if (name == "atmega328p") {
            _chip_type = CHIP_ATMEGA_328P;
            _sp.send_ok();
        } else {
            _chip_type = CHIP_NONE;
            _sp.send_error("bad chip");
        }
    }

    ChipType chip_type() {
        return _chip_type;
    }

    // TODO rename send hex

    void begin();
    void send_hex();
    void end();

private:
    StringPort &_sp;
    ChipType _chip_type;

    void ATmega328P_begin();
    void ATmega328P_send_hex();
    void ATmega328P_end();
};

void Programmer::begin() {
    _sp.receive();

    switch(_chip_type) {
    case CHIP_NONE:
        _sp.send_ok();
        return;
    case CHIP_ATMEGA_328P:
        ATmega328P_begin();
        break;
    }
}

void Programmer::send_hex() {
    switch(_chip_type) {
    case CHIP_NONE:
        _sp.send_ok();
        return;
    case CHIP_ATMEGA_328P:
        ATmega328P_send_hex();
        break;
    }
}

void Programmer::end() {
    switch(_chip_type) {
    case CHIP_NONE:
        _sp.send_ok();
        return;
    case CHIP_ATMEGA_328P:
        ATmega328P_end();
        break;
    }
}

void Programmer::ATmega328P_begin() {
    spi_init_pins();

    digitalWrite(P_RESET, LOW);
    digitalWrite(P_SCK, LOW);
    delay(20);

    digitalWrite(P_RESET, HIGH);
    delayMicroseconds(200);
    digitalWrite(P_RESET, LOW);

    delay(40);

    SPI.begin();
    SPI.beginTransaction(SPISettings(1000000/6, MSBFIRST, SPI_MODE0));


    // sync
    uint8_t sync = spi_transfer3(0xAC530000);
    if (sync != 0x53) {
        // TODO reset again
        _sp.send_warning("bad sync byte, resetting chip");
        return;
    }

    uint8_t sig_bytes[3];
    sig_bytes[0] = spi_transfer4(0x30, 0x00, 0x00, 0x00);
    sig_bytes[1] = spi_transfer4(0x30, 0x00, 0x01, 0x00);
    sig_bytes[2] = spi_transfer4(0x30, 0x00, 0x02, 0x00);

    if (!(sig_bytes[0] == 0x1e &&
          sig_bytes[1] == 0x95 &&
          sig_bytes[2] == 0x0F)) {
        _sp.send_warning("incorrect signature bytes");
    }

    // chip erase
    spi_transfer4(0xAC800000);

    delay(15);

    _sp.send_ok("begin atmega328p");
}

void Programmer::ATmega328P_send_hex() {
    _sp.receive();
    _sp.send_ok();
}

void Programmer::ATmega328P_end() {
    _sp.receive();

    SPI.endTransaction();
    SPI.end();

    pinMode(P_MOSI, INPUT);
    pinMode(P_SCK, INPUT);
    digitalWrite(P_RESET, HIGH);
    pinMode(P_RESET, INPUT);

    _sp.send_ok();
}

//

StringPort sp;
Programmer prog(sp);

void setup() {
    pinMode(P_LED, OUTPUT);
    digitalWrite(P_LED, LOW);

    sp.init();
    sp.send_ok();
}

void loop() {
    String str = sp.receive();

    if (str.startsWith("set:")) {
        str = str.substring(4);
        if (str.startsWith("chip:")) {
            prog.set_chip(str.substring(5));
        }

    } else if (str.startsWith("get:")) {
        str = str.substring(4);
        sp.send_ok();

    } else if (str.startsWith("hex")) {
        if (prog.chip_type() == CHIP_NONE) {
            sp.send_error("no chip set");
        } else {
            sp.send_ok();

            prog.begin();
            prog.send_hex();
            prog.end();
        }
    }
}
