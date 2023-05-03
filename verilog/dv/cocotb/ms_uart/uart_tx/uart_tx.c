#include <ms_uart.h>
#include <common.h>
void main(void){
    enable_user_interface();
    mgmt_gpio_wr(0);
    mgmt_gpio_o_enable();
    ms_uart_set_prescaler(50);
    ms_uart_enable();
    ms_uart_enable_tx();
    mgmt_gpio_wr(1);
    ms_uart_write_data("Hello World!\n");
}