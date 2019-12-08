#ifndef UO_PROGRAMMER_MAIN_H
#define UO_PROGRAMMER_MAIN_H

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

    String receive_string();
    void transmit_string(const String &);

    void send_done(const String &);
    void send_fail(const String &);
    void send_msg(const String &);
    void send_warning(const String &);

private:
    uint8_t _buf[PCPORT_MAX_RECV_LEN + 1];

    int receive();
    void transmit(const uint8_t *buf, unsigned int sz);

    void _send_message(const char *, const String &);
};

enum ChipType {
    CHIP_NONE ,
    CHIP_ATMEGA_328P
};

enum HexLineType {
    HEX_TYPE_DATA = 0 ,
    HEX_TYPE_EOF = 1
};

enum HexLineErrCode {
    HEX_LINE_OK ,
    HEX_LINE_EOF ,
    HEX_LINE_ERROR
};


class Programmer {
public:
    Programmer(PCPort &pcp)
    : _pcp(pcp) {
        _chip_type = CHIP_NONE;
    }

    void set_chip(const String &name) {
        if (name == "atmega328p") {
            _chip_type = CHIP_ATMEGA_328P;
            _pcp.send_done("set chip");
        } else {
            _chip_type = CHIP_NONE;
            _pcp.send_fail("bad chip");
        }
    }

    ChipType chip_type() {
        return _chip_type;
    }

    // TODO rename send hex

    void begin();
    void end();
    void send_hex();
    void set_fuses(const String &to);

private:
    PCPort &_pcp;
    ChipType _chip_type;

    void ATmega328P_begin();
    void ATmega328P_end();
    void ATmega328P_send_hex();
    void ATmega328P_set_fuses(const String &to);

    uint16_t ATmega328P_flash_page_of(uint16_t addr);
    void ATmega328P_load_flash_word(uint16_t addr, uint16_t word);
    void ATmega328P_write_flash_page(uint16_t addr);
    HexLineErrCode ATmega328P_write_hex_line(const String &line);
};

#endif
