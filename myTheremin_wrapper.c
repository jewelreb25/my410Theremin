extern int myTheremin(void);
extern int updateFreq(int);
extern int updateVolume(int);

typedef struct{
    int pitch;
    int volume;
}adcInput;
extern int poll_ADC(adcInput* temp);
void smooth_adc(adcInput* );

int main(){
  myTheremin();
  adcInput notePlayed;
  int minFreq= 318;
  int maxFreq= 955;
  int adcMax= 4095;
  int adcNoHand= 3200;
  int lastFreq = 0;
  int lastVolume = 0;
  int adcVolMax = 4095;

while(1) {
  smooth_adc(&notePlayed);
  int pitchRead= notePlayed.pitch; //the pitch is the avg of the pitches read
  int volumeRead=notePlayed.volume;
  if(pitchRead>=adcNoHand){ //turn off for when no hand is present
      updateFreq(0);
      updateVolume(0);
      continue;
  }
  int freq = minFreq + ((maxFreq - minFreq) * pitchRead) / adcMax;
  if(freq != lastFreq) {       //only update if the note changes
      updateFreq(freq);
      lastFreq = freq;
  }
  int volume_duty_cycle = (freq * volumeRead) / adcVolMax;
  if(volume_duty_cycle != lastVolume) {
      updateVolume(volume_duty_cycle); //update cmp value
      lastVolume = volume_duty_cycle;
  }
  }
}

void smooth_adc(adcInput* rawReading){
   int avgPitch=0,avgVolume= 0;
   int i=0;
   adcInput temp;
   for(; i < 16; i++){
     poll_ADC(&temp);
     avgPitch+= temp.pitch;
     avgVolume+=temp.volume;
   }
   rawReading->pitch=(avgPitch/16);
   rawReading->volume=(avgVolume/16);
}
