#include <common.h>
#include <ms_timer.h>

unsigned int xorshift32(unsigned int *state); 

void main(void){
    mgmt_gpio_wr(0);
    mgmt_gpio_o_enable();
    enable_user_interface();
    unsigned int seed = SEED; // Initial seed value
    unsigned int state = seed;
    // use gpios 0 to 31 as mgmt out
    // to populate the match number 
    for (int i = 0; i < 32; i++){
        configure_gpio(i,GPIO_MODE_MGMT_STD_OUTPUT);
    }
    // configure gpio 33 as user input to for sending pusles over it 
    configure_gpio(33,GPIO_MODE_USER_STD_INPUT_PULLDOWN);
    // load configs 
    gpio_config_load();

    int match_pulses = xorshift32(&state) & 0xFF; // make it smaller than 0xFF
    TMR_setCounterMatch(match_pulses);
    set_gpio_l(match_pulses);
    // configure need for counter enable
    TMR_tmrEn(1);
    TMR_setClkSrc(0x9);
    TMR_timerUp(1);
    TMR_setTimerPeriod(match_pulses + 0x20);
    // Enable the counter interrupt matrch flag
    clear_flag();
    enable_user0_irq(1);
    TMR_setInterruptMask(0x4);
    

    mgmt_gpio_wr(1); // configuration finished 
    while(1){
        if (get_flag() == 1){
            mgmt_gpio_wr(0); 
            return;
        }
    }    
}

unsigned int xorshift32(unsigned int *state){
    unsigned int x = *state;
    x ^= x << 13;
    x ^= x << 17;
    x ^= x >> 5;
    x &= 0xFFFF7FFF; // fix io 15 to 0 because it is connected to Aout
    *state = x;
    return x;
}

