#include <common.h>
#include <ms_timer.h>

void main(void){
    mgmt_gpio_wr(0);
    mgmt_gpio_o_enable();
    enable_user_interface();
    // use gpio 6 as uart TX
    configure_gpio(6,GPIO_MODE_MGMT_STD_OUTPUT);
    // use gpio 33  as capture input
    configure_gpio(33,GPIO_MODE_USER_STD_INPUT_NOPULL);
    gpio_config_load();
    enable_uart_TX(1);
    // IRQ enable
    clear_flag();
    enable_user0_irq(1);
    TMR_setInterruptMask(0x2);
    // capture rising edge 
    TMR_captureRising();
    TMR_cpEn(1);
    TMR_setClkSrc(0x8);
    mgmt_gpio_wr(1); // start the capture
    while(1){
        if (get_flag() == 1){
            uart_put_int(TMR_getCounterVal());
            break;
        }
    }


    // clear IRQ
    TMR_cpEn(0);
    TMR_tmrEn(0);
    TMR_clearInterrupt(0x2);
    enable_user0_irq(0);
    enable_user0_irq(1);
    clear_flag();
    // capture falling edge 
    TMR_captureFalling();
    TMR_cpEn(1);
    mgmt_gpio_wr(0); // start the capture
    while(1){
        if (get_flag() == 1){
            uart_put_int(TMR_getCounterVal());
            break;
        }
    }


    // clear IRQ
    TMR_cpEn(0);
    TMR_tmrEn(0);
    TMR_clearInterrupt(0x2);
    enable_user0_irq(0);
    enable_user0_irq(1);
    clear_flag();
    // capture falling edge 
    TMR_captureBoth();
    TMR_cpEn(1);
    mgmt_gpio_wr(1); // start the capture
    while(1){
        if (get_flag() == 1){
            uart_put_int(TMR_getCounterVal());
            break;
        }
    }
}

