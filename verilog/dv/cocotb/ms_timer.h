#ifndef MS_TIMER_H
#define MS_TIMER_H

#define SEED 0x745487

char *ms_timer_base = (char *) 0x30000000;
void TMR_tmrEn(bool is_en){
    if (is_en)
        (*(volatile int*)(ms_timer_base + 0x100)) |= 0x3;
    else
        (*(volatile int*)(ms_timer_base + 0x100)) &= ~0x3;
}
void TMR_pwmEn(bool is_en){
    if (is_en)
        (*(volatile int*)(ms_timer_base + 0x100)) |= 0x7;
    else
        (*(volatile int*)(ms_timer_base + 0x100)) &= ~0x7;
}

void TMR_cpEn(bool is_en){
    if (is_en)
        (*(volatile int*)(ms_timer_base + 0x100)) |= 0x9;
    else
        (*(volatile int*)(ms_timer_base + 0x100)) &= ~0x9;
}

void TMR_setClkSrc(int clk_src){
    int tmp = clk_src << 8;
    tmp = tmp & 0xF00;
    *(volatile int*)(ms_timer_base + 0x100) |= tmp;
}
void TMR_timerUp(bool is_up){
    if (is_up)
        (*(volatile int*)(ms_timer_base + 0x100)) |= 0x10000;
    else
        (*(volatile int*)(ms_timer_base + 0x100)) &= ~0x10000;
}

void TMR_timerOneShot(bool is_one_shot){
    if (is_one_shot)
        (*(volatile int*)(ms_timer_base + 0x100)) |= 0x20000;
    else
        (*(volatile int*)(ms_timer_base + 0x100)) &= ~0x20000;
}

void TMR_setCpEvent(int cp_event){
    int tmp = cp_event << 23;
    tmp = tmp & 0x6000000;
    *(volatile int*)(ms_timer_base + 0x100) |= tmp;
}

void TMR_setCounterMatch(int match){
    *(volatile int*)(ms_timer_base + 0x0C) = match;
}

void TMR_setPWM_dutyCycle(int duty_cycle){
    *(volatile int*)(ms_timer_base + 0x08) = duty_cycle;
}

void TMR_setTimerPeriod(int period){
    *(volatile int*)(ms_timer_base + 0x04) = period;
}

int TMR_getTimerPeriod(){
    return *(volatile int*)(ms_timer_base + 0x00);
}


void TMR_setInterruptMask(int mask){
    // bit 0: Time-out Flag
    // bit 1: Capture Flag
    // bit 2: Match Flag
    (*(volatile int*)(ms_timer_base + 0x208)) = mask;
}

void TMR_clearInterrupt(int mask){
    // bit 0: Time-out Flag
    // bit 1: Capture Flag
    // bit 2: Match Flag
    (*(volatile int*)(ms_timer_base + 0x20C)) = mask;
}

#endif // MS_TIMER_H