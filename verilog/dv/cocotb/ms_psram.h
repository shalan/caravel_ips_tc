#ifndef MS_SPRAM_H
#define MS_SPRAM_H

#define SEED 0x745487
// 
char *ms_psram_base = (char *) 0x30040000;

void SPRAM_writeWord(unsigned int data,int offset){
    *(((unsigned int *) ms_psram_base)+offset) = data;
}

int SPRAM_readWord(int offset){
    return *(((unsigned int *) ms_psram_base)+offset);
}

void SPRAM_writeHalfWord(unsigned short data,unsigned int offset,bool is_first_word){
    unsigned int half_word_offset = offset *2 + is_first_word;
    *(((unsigned short *) ms_psram_base)+half_word_offset) = data;
}
unsigned short SPRAM_readHalfWord(unsigned int offset,bool is_first_word){
    unsigned int half_word_offset = offset *2 + is_first_word;
    return *(((unsigned int *) ms_psram_base)+half_word_offset);
}

void SPRAM_writeByte(unsigned char data,unsigned int offset,unsigned char byte_num){
    if (byte_num > 3) 
        byte_num =0; 
    unsigned int byte_offset = offset *4 + byte_num;
    *(((unsigned char *) ms_psram_base)+byte_offset) = data;
}
unsigned char SPRAM_readByte(unsigned int offset,unsigned char byte_num){
    if (byte_num > 3) 
        byte_num =0; 
    unsigned int byte_offset = offset *4 + byte_num;
    return *(((unsigned int *) ms_psram_base)+byte_offset);
}
#endif // MS_SPRAM_H