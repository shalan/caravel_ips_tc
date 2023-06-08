#include <common.h> 
#include <ms_psram.h>

// generate random number
unsigned int xorshift32(unsigned int *state, bool is_addr, bool is_half_word, bool is_byte) {
    unsigned int x = *state;
    x ^= x << 13;
    x ^= x << 17;
    x ^= x >> 5;
    *state = x;
    if (is_addr){
        // address offset can take values up to 0x3FFF
        x = x & 0x3FFF; 
        return x;
    }else if (is_half_word){
        return x & 0xFFFF;
    }else if (is_byte){
        return x & 0xFF;
    }
    return x;
}


void main(void){
    unsigned int seed = SEED; // Initial seed value
    unsigned int state = seed;
    enable_user_interface();
    mgmt_gpio_wr(0);
    mgmt_gpio_o_enable();
    enable_uart_TX(1);
    configure_gpio(6,GPIO_MODE_MGMT_STD_OUTPUT);
    
    configure_gpio(31,GPIO_MODE_USER_STD_OUTPUT); // CS 
    configure_gpio(30,GPIO_MODE_USER_STD_OUTPUT); // SCK
    // MOSI
    configure_gpio(36,GPIO_MODE_USER_STD_BIDIRECTIONAL);
    configure_gpio(37,GPIO_MODE_USER_STD_BIDIRECTIONAL);
    configure_gpio(28,GPIO_MODE_USER_STD_BIDIRECTIONAL);
    configure_gpio(29,GPIO_MODE_USER_STD_BIDIRECTIONAL);
    // // MISO
    // configure_gpio(26,GPIO_MODE_USER_STD_INPUT_NOPULL); 
    // configure_gpio(27,GPIO_MODE_USER_STD_INPUT_NOPULL); 
    // configure_gpio(0,GPIO_MODE_USER_STD_INPUT_NOPULL); 
    // configure_gpio(1,GPIO_MODE_USER_STD_INPUT_NOPULL); 

    gpio_config_load();
    mgmt_gpio_wr(1);
    int offset = xorshift32(&state, 1, 0, 0);
    int data = xorshift32(&state, 0, 0, 0);
    SPRAM_writeWord(data, offset);
    int read_data = SPRAM_readWord(offset);
    if (read_data == data){
        print("P1\n");
        uart_put_int(read_data);
    }
    else{
        print("F1\n");
        uart_put_int(read_data);
        uart_put_int(data);
    }


    offset = xorshift32(&state, 1, 0, 0);
    data = xorshift32(&state, 0, 0, 0);
    SPRAM_writeWord(data, offset);
    int data_half = xorshift32(&state, 0, 1, 0);
    SPRAM_writeHalfWord(data_half, offset,1);
    data_half = (data_half << 16);
    int data_expected = (data & 0xFFFF);
    data_expected |= data_half;
    read_data = SPRAM_readWord(offset);
    if (read_data == data_expected){
        print("P2\n");
        uart_put_int(read_data);
    }
    else{
        print("F2\n");
        uart_put_int(read_data);
        uart_put_int(data_expected);
    }


    int data_byte = xorshift32(&state, 0, 0, 1);
    SPRAM_writeByte(data_byte, offset, 1);
    read_data = SPRAM_readWord(offset);
    data_expected = (data_expected & 0xFFFF00FF) | data_byte<<8;
    if (read_data == data_expected){
        print("P3\n");
        uart_put_int(read_data);
    }else{
        print("F3\n");
        uart_put_int(read_data);
        uart_put_int(data_expected);
    }
}

