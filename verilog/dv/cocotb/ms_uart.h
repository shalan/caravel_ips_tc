#ifndef MS_UART_H 
#define MS_UART_H


char *ms_uart_base = (char *) 0x30020000;

void ms_uart_enable(){
    (*(volatile int*)(ms_uart_base + 0x100)) |= 0x1;
}

void ms_uart_disable(){
    (*(volatile int*)(ms_uart_base + 0x100)) &= 0xFFFFFFFE;
}
void ms_uart_enable_rx(){
    (*(volatile int*)(ms_uart_base + 0x100)) |= 0x4;
}

void ms_uart_disable_rx(){
    (*(volatile int*)(ms_uart_base + 0x100)) &= 0xFFFFFFFB;
}

void ms_uart_enable_tx(){
    (*(volatile int*)(ms_uart_base + 0x100)) |= 0x2;
}

void ms_uart_disable_tx(){
    (*(volatile int*)(ms_uart_base + 0x100)) &= 0xFFFFFFFD;
}

void ms_uart_set_tx_fifo_level(int level){
    (*(volatile int*)(ms_uart_base + 0x008)) = level;
}

int ms_uart_get_tx_fifo_level(){
    return (*(volatile int*)(ms_uart_base + 0x008));
}
void ms_uart_set_rx_fifo_level(int level){
    (*(volatile int*)(ms_uart_base + 0x00C)) = level;
}

int ms_uart_get_rx_fifo_level(){
    return (*(volatile int*)(ms_uart_base + 0x00C));
}

void ms_uart_set_prescaler(int baudrate){
    (*(volatile int*)(ms_uart_base + 0x004)) = baudrate;
}

int ms_uart_get_prescaler(){
    return (*(volatile int*)(ms_uart_base + 0x004));
}

void ms_uart_write_data(const char *p){
    while (*p)
        (*(volatile int*)(ms_uart_base + 0x000)) = *(p++);
}

void ms_uart_write_int(int data){
    (*(volatile int*)(ms_uart_base + 0x000)) = data;
}
int ms_uart_read_data(){
    while(ms_uart_get_RIS() & 0x10 == 0x10); // wait over RX fifo is empty Flag to unset  
    return (*(volatile int*)(ms_uart_base + 0x000));
}

int ms_uart_get_RIS(){
    return (*(volatile int*)(ms_uart_base + 0x200));
}

int ms_uart_get_MIS(){
    return (*(volatile int*)(ms_uart_base + 0x204));
}

void ms_uart_set_interrupt_mask(int mask){
    // bit 0: TX fifo is full Flag
    // bit 1: TX fifo is empty Flag
    // bit 2: TX fifo level is below threshold
    // bit 3: RX fifo is full Flag
    // bit 4: RX fifo is empty Flag
    // bit 5: RX fifo level is above threshold
    (*(volatile int*)(ms_uart_base + 0x208)) = mask;
}

int ms_uart_get_interrupt_mask(int mask){
    return (*(volatile int*)(ms_uart_base + 0x208));
}

void ms_uart_clear_interrupts(){
    (*(volatile int*)(ms_uart_base + 0x20C)) = 1;
}
#endif // MS_UART_H