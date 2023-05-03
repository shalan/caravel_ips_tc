#include <ms_uart.h>
#include <common.h>

void main(void){
    enable_user_interface();
    mgmt_gpio_wr(0);
    mgmt_gpio_o_enable();
    ms_uart_enable();
    ms_uart_enable_rx();
    mgmt_gpio_wr(1);
    int a = ms_uart_read_data();
    int x = ms_uart_read_data();
    mgmt_gpio_wr(0);
    ms_uart_enable_tx();
    char a_char = (char)a;
    char x_char = (char)x;
    ms_uart_write_int(a);
    ms_uart_write_int(x);
}