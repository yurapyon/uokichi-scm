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

    void send_sync(bool);
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
    HEX_LINE_TYPE_DATA = 0 ,
    HEX_LINE_TYPE_EOF = 1
};

enum HexLineErrorCode {
    HEX_LINE_ERR_OK ,
    HEX_LINE_ERR_EOF ,
    HEX_LINE_ERR_ERROR
};

// TODO bool for programming or not

class Programmer {
public:
    Programmer(PCPort &pcp)
    : _pcp(pcp) {
        _chip_type = CHIP_NONE;
    }

    ChipType chip_type() {
        return _chip_type;
    }

    // TODO rename send hex

    void set_chip(const String &name);
    void begin();
    void end();
    void write_hex();
    void set_fuses(const String &to);

private:
    PCPort &_pcp;
    ChipType _chip_type;

    void ATmega328P_begin();
    void ATmega328P_end();
    void ATmega328P_write_hex();
    void ATmega328P_set_fuses(const String &to);

    uint16_t ATmega328P_flash_page_of(uint16_t addr);
    void ATmega328P_load_flash_word(uint16_t addr, uint16_t word);
    uint16_t ATmega328P_read_flash_word(uint16_t addr);
    void ATmega328P_write_flash_page(uint16_t addr);
    HexLineErrorCode ATmega328P_write_hex_line(const String &line);
};

#endif
