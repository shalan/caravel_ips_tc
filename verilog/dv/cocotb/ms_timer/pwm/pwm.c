#include <common.h>
#include <ms_timer.h>

void main(void){
    mgmt_gpio_wr(0);
    mgmt_gpio_o_enable();
    enable_user_interface();
    uart_RX_enable(1);
    // configure gpio 32 as output for pwm_out
    configure_gpio(32,GPIO_MODE_USER_STD_OUTPUT);
    // configure gpio 5 as mgmt input for uart
    configure_gpio(5,GPIO_MODE_MGMT_STD_INPUT_NOPULL);
    // load configs 
    gpio_config_load();
    mgmt_gpio_wr(1);
    char cycle = uart_getc();
    TMR_setTimerPeriod(cycle);
    TMR_setPWM_dutyCycle(cycle/2);
    TMR_pwmEn(1);
    mgmt_gpio_wr(0);
}





