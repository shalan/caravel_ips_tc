#include <common.h>
#include <ms_timer.h>
void main(void){
    mgmt_gpio_wr(0);
    mgmt_gpio_o_enable();
    enable_user_interface();
    for (int i = 0; i < 3; i++){
         configure_gpio(i,GPIO_MODE_MGMT_STD_OUTPUT);
    }
    // load configs 
    gpio_config_load();

    // one shot 
    TMR_timerOneShot(1); 
    TMR_setTimerPeriod(0x7FF);
    TMR_setClkSrc(0x0);
    // one shot mode up counting
    TMR_timerUp(1);
    // IRQ enable
    clear_flag();
    enable_user0_irq(1);
    TMR_setInterruptMask(0x1);
    // timer enable
    TMR_tmrEn(1);

     while(1){
        if (get_flag() == 1){
            mgmt_gpio_wr(1); // found first flag
            break;
        }
    }
    // clear IRQ
    TMR_tmrEn(0);
    TMR_clearInterrupt(0x1);
    enable_user0_irq(0);
    enable_user0_irq(1);
    clear_flag();
    // periodic mode
    // timer enable
    TMR_timerOneShot(0); 
    TMR_tmrEn(1);
     while(1){
        if (get_flag() == 1){
            mgmt_gpio_wr(0); // found first flag
            break;
        }
    }
}
