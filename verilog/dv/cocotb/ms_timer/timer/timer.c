#include <common.h>
#include <ms_timer.h>

bool get_gpio16();

void main(void){
    mgmt_gpio_wr(0);
    mgmt_gpio_o_enable();
    enable_user_interface();
    unsigned int seed = SEED; // Initial seed value
    unsigned int state = seed;
    // use gpios 0 to 14 as mgmt out
    // to populate the timer values
    for (int i = 0; i < 32; i++){
        if (i==16)
            configure_gpio(i,GPIO_MODE_MGMT_STD_INPUT_NOPULL); 
        else
            configure_gpio(i,GPIO_MODE_MGMT_STD_OUTPUT);
    }
    // load configs 
    gpio_config_load();

    // one shot 
    TMR_timerOneShot(1); 
    TMR_setTimerPeriod(0x7FF);
    TMR_setClkSrc(0x4);
    mgmt_gpio_wr(1); // configuration finished
    // one shot mode up counting
    TMR_timerUp(1);
    TMR_tmrEn(1);
    while(true){
        set_gpio_l(TMR_getTimerPeriod());   
        if (get_gpio16()){
            TMR_tmrEn(0);
            break;

        }
    }
    // one shot mode down counting
    TMR_timerUp(0);
    TMR_tmrEn(1);
    while(true){
        set_gpio_l(TMR_getTimerPeriod());   
        if (!get_gpio16()){
            TMR_tmrEn(0);
            break;

        }
    }

    // periodic mode 
    TMR_timerOneShot(0); 
    // periodic mode up counting
    TMR_timerUp(1);
    TMR_tmrEn(1);
    while(true){
        set_gpio_l(TMR_getTimerPeriod());   
        if (get_gpio16()){
            TMR_tmrEn(0);
            break;
        }
    }
    // periodic mode down counting
    TMR_timerUp(0);
    TMR_tmrEn(1);
    while(true){
        set_gpio_l(TMR_getTimerPeriod());   
    }

}

bool get_gpio16(){
    int val = get_gpio_l() >> 16;
    val &= 0x1;
    set_gpio_h(val << 4);
    return val;
}