#include <ms_uart.h>
#include <common.h>

void main(void){
    enable_user_interface();
    clear_flag();
    enable_user1_irq(1);
    mgmt_gpio_wr(0);
    mgmt_gpio_o_enable();
    ms_uart_enable();
    ms_uart_enable_rx();
    ms_uart_set_interrupt_mask(0x8);// enable RX full interrupt
    mgmt_gpio_wr(1);
    int timeout = 5000; // wait until the fifo is full the irq suppose to be set 
    for (int i = 0; i < timeout; i++){
        if (get_flag() == 1){
            mgmt_gpio_wr(0); //test pass irq sent at mprj 12 
            return;
        }
    }    
}