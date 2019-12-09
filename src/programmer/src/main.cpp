#include <Arduino.h>
#include <SPI.h>

#include "main.hpp"

uint8_t hr_nibble_to_byte(char nibble) {
    if (nibble >= '0' && nibble <= '9') {
        return nibble - 0x30;
    } else if (nibble >= 'A' && nibble <= 'F') {
        return 0xA + (nibble - 0x41);
    } else if (nibble >= 'a' && nibble <= 'f') {
        return 0xA + (nibble - 0x61);
    } else {
        return 0;
    }
}

uint8_t hr_byte_to_byte(const char *byte) {
    return (hr_nibble_to_byte(byte[0]) << 4)
          | hr_nibble_to_byte(byte[1]);
}

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

#define spi_transfer4_u32(_val) \
  spi_transfer4((_val >> 24) & 0xff \
              , (_val >> 16) & 0xff \
              , (_val >>  8) & 0xff \
              , _val & 0xff)

#define spi_transfer3_u32(_val) \
  spi_transfer3((_val >> 24) & 0xff \
              , (_val >> 16) & 0xff \
              , (_val >>  8) & 0xff \
              , _val & 0xff)

void spi_init_pins() {
    pinMode(P_MOSI, OUTPUT);
    pinMode(P_MISO, INPUT);
    pinMode(P_SCK, OUTPUT);
    pinMode(P_RESET, OUTPUT);
}

//

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

void PCPort::_send_message(const char *base, const String &msg) {
    String str(base);
    str.concat(msg);
    transmit_string(str);
}

String PCPort::receive_string() {
    receive();
    return String((const char *)_buf);
}

void PCPort::transmit_string(const String &str) {
    transmit((const uint8_t *)str.c_str(), str.length());
}

void PCPort::send_done(const String &str) {
    _send_message("done:", str);
}

void PCPort::send_fail(const String &str) {
    _send_message("fail:", str);
}

void PCPort::send_msg(const String &str) {
    _send_message("msg:", str);
}

void PCPort::send_warning(const String &str) {
    _send_message("warn:", str);
}

//

// TODO bool for programming or not

void Programmer::begin() {
    switch(_chip_type) {
    case CHIP_NONE:
        _pcp.send_fail("no chip set");
        return;
    case CHIP_ATMEGA_328P:
        ATmega328P_begin();
        break;
    }
}

void Programmer::end() {
    switch(_chip_type) {
    case CHIP_NONE:
        _pcp.send_fail("no chip set");
        return;
    case CHIP_ATMEGA_328P:
        ATmega328P_end();
        break;
    }
}

void Programmer::send_hex() {
    switch(_chip_type) {
    case CHIP_NONE:
        _pcp.send_fail("no chip set");
        return;
    case CHIP_ATMEGA_328P:
        ATmega328P_send_hex();
        break;
    }
}

void Programmer::set_fuses(const String &str) {
    switch(_chip_type) {
    case CHIP_NONE:
        _pcp.send_fail("no chip set");
        return;
    case CHIP_ATMEGA_328P:
        ATmega328P_set_fuses(str);
        break;
    }
}

// ATmega328P

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
    SPI.beginTransaction(SPISettings(1000000 / 6, MSBFIRST, SPI_MODE0));

    // sync
    uint8_t sync = spi_transfer3_u32(0xAC530000);
    if (sync != 0x53) {
        _pcp.send_warning("bad sync byte, resetting chip");
        // TODO try reset again
        _pcp.send_fail("unimplemented");
        return;
    }

    // signature
    uint8_t sig_bytes[3];
    sig_bytes[0] = spi_transfer4_u32(0x30000000);
    sig_bytes[1] = spi_transfer4_u32(0x30000100);
    sig_bytes[2] = spi_transfer4_u32(0x30000200);

    if (!(sig_bytes[0] == 0x1e &&
          sig_bytes[1] == 0x95 &&
          sig_bytes[2] == 0x0F)) {
        _pcp.send_fail("incorrect signature bytes");
    }

    // chip erase
    spi_transfer4_u32(0xAC800000);

    delay(15);

    _pcp.send_done("atmega328p begin");
}

void Programmer::ATmega328P_end() {
    SPI.endTransaction();
    SPI.end();

    pinMode(P_MOSI, INPUT);
    pinMode(P_SCK, INPUT);
    digitalWrite(P_RESET, HIGH);
    pinMode(P_RESET, INPUT);

    _pcp.send_done("atmega328p end");
}

void Programmer::ATmega328P_send_hex() {
    String hexfile(
        ":10000000940c00340000000000000000000000001c\n"
        ":1000080000000000000000000000000000000000e8\n"
        ":1000100000000000000000000000000000000000e0\n"
        ":1000180000000000000000000000000000000000d8\n"
        ":1000200000000000000000000000000000000000d0\n"
        ":1000280000000000000000000000000000000000c8\n"
        ":080030000000000000000000c8\n"
        ":0a0034009a3d9a45c0009845cffca4\n"
        ":00000001ff\n");
    int start = 0;
    int end = -1;

    while(true) {
        int found = hexfile.indexOf('\n', start);
        if (found == -1) {
            break;
        }
        end = found;
        ATmega328P_write_hex_line(hexfile.substring(start, end));
        // _pcp.send_msg(hexfile.substring(start, end));
        start = found + 1;
    }

    _pcp.send_done("atmega328p hex");
}

void Programmer::ATmega328P_set_fuses(const String &str) {
    _pcp.send_done("atmega328p fuses");
}


uint16_t Programmer::ATmega328P_flash_page_of(uint16_t addr) {
    return addr & 0xffc0;
}

void Programmer::ATmega328P_load_flash_word(uint16_t addr, uint16_t word) {
    // write low byte first
    // see atmega328p datasheet, 31.8.2 Serial Programming Algorithm, step 4
    spi_transfer4(0x40, 0x00, addr, word);
    spi_transfer4(0x48, 0x00, addr, word >> 8);
}

uint16_t Programmer::ATmega328P_read_flash_word(uint16_t addr) {
    uint8_t low = spi_transfer4(0x20, addr >> 8, addr, 0x00);
    uint8_t high = spi_transfer4(0x28, addr >> 8, addr, 0x00);
    uint16_t ret = high;
    ret = (ret << 8) | low;
    return ret;
}

void Programmer::ATmega328P_write_flash_page(uint16_t addr) {
    spi_transfer4(0x4c, addr >> 8, addr, 0x00);

    // wait 2.6 ms, see datasheet
    delay(5);
}

// TODO something like parse hex line to a struct or something

HexLineErrCode Programmer::ATmega328P_write_hex_line(const String &line) {
    // hex line
    // ":SZaddrTYdatadata....ch"
    //  01 3   7 9

    const char *cline = line.c_str();

    if (cline[0] != ':') {
        _pcp.send_warning("invalid hex line");
        return HEX_LINE_ERROR;
    }

    uint8_t word_ct = hr_byte_to_byte(cline + 1) / 2;
    uint8_t addr_high = hr_byte_to_byte(cline + 3);
    uint8_t addr_low = hr_byte_to_byte(cline + 5);
    uint8_t type = hr_byte_to_byte(cline + 7);

    if (type == HEX_TYPE_EOF) {
        return HEX_LINE_EOF;
    }

    if (type != HEX_TYPE_DATA) {
        _pcp.send_warning("invalid hex line");
        return HEX_LINE_ERROR;
    }

    // check hex line is valid
    //  make sure addresses are in bounds
    //  size matches up
    //  check checksum?

    uint16_t addr = addr_high;
    addr = (addr << 8) | addr_low;
    uint16_t page = ATmega328P_flash_page_of(addr);

    _pcp.send_msg(line);
    // _pcp.send_msg(String(word_ct, HEX));
    // _pcp.send_msg(String(addr, HEX));
    // _pcp.send_msg(String(type, HEX));

    uint16_t curr_addr = addr;
    uint16_t curr_page = page;

    cline += 9;

    for (int i = 0; i < word_ct; ++i) {
        uint8_t data_high = hr_byte_to_byte(cline + i * 4);
        uint8_t data_low = hr_byte_to_byte(cline + i * 4 + 2);
        uint16_t data = data_high;
        data = (data << 8) | data_low;

        ATmega328P_load_flash_word(curr_addr, data);

        // TODO make sure this works
        if(curr_page != ATmega328P_flash_page_of(curr_addr + 1)) {
            // if you dont have data to write after this
            //   just break and let the finalizer write this page
            if (i + 1 >= word_ct) {
                break;
            }

            ATmega328P_write_flash_page(curr_addr);
            curr_page = ATmega328P_flash_page_of(curr_addr + 1);
        }

        curr_addr++;
    }

    ATmega328P_write_flash_page(curr_addr);

    cline = line.c_str() + 9;
    curr_addr = addr;

    for (int i = 0; i < word_ct; ++i) {
        uint8_t data_high = hr_byte_to_byte(cline + i * 4);
        uint8_t data_low = hr_byte_to_byte(cline + i * 4 + 2);
        uint16_t data = data_high;
        data = (data << 8) | data_low;
        // _pcp.send_msg(String(data, HEX));

        uint16_t from_chip = ATmega328P_read_flash_word(curr_addr);
        // _pcp.send_msg(String(from_chip, HEX));

        // TODO check write went ok

        curr_addr++;
    }

    // TODO handle eeprom addr (addr > 0x8000)

    return HEX_LINE_OK;
}

//

PCPort pcp;
Programmer prog(pcp);

void setup() {
    pinMode(P_LED, OUTPUT);
    digitalWrite(P_LED, LOW);

    PCPortSettings pcps;
    pcp.init(pcps);
    pcp.send_done("hello");
}

void loop() {
    String str = pcp.receive_string();

    if (str.startsWith("set:")) {
        str = str.substring(4);
        if (str.startsWith("chip:")) {
            prog.set_chip(str.substring(5));
        } else if (str.startsWith("fuses:")) {
            prog.set_fuses(str.substring(6));
        }

    } else if (str.startsWith("get:")) {
        str = str.substring(4);
        pcp.send_done("get");

    } else if (str.startsWith("prog:")) {
        str = str.substring(5);
        if (str.startsWith("begin")) {
            prog.begin();
        } else if (str.startsWith("end")) {
            prog.end();
        } else if (str.startsWith("send_hex")) {
            prog.send_hex();
        }
    }
}
