extern int myTheremin(void);
extern int poll_ADC(void);
extern int updateFreq(int);

int smooth_adc(void);

int main(){
  myTheremin();
  while(1){
      int valueRead=smooth_adc();
      if(valueRead>0&& valueRead<450){
          updateFreq(318);
      }
      else if(valueRead>451&& valueRead<800){
                updateFreq(357);
      }
      else if(valueRead>801&& valueRead<1150){
                updateFreq(379);
      }
      else if(valueRead>1151&& valueRead<1500){
                updateFreq(425);
      }
      else if(valueRead>1501&& valueRead<1850){
                updateFreq(477);
      }
      else if(valueRead>1851&& valueRead<2200){
                updateFreq(506);
      }
      else if(valueRead>2201&& valueRead<2250){
                updateFreq(567);
      }
      else if(valueRead>2251&& valueRead<2700){
                updateFreq(637);
      }
      else if(valueRead>2701&& valueRead<2900){
                updateFreq(715);
      }
      else if(valueRead>2901&& valueRead<3000){
                updateFreq(758);
      }
      else if(valueRead>3000&& valueRead<3800){
                updateFreq(850);
      }
      else if(valueRead>3800&& valueRead<3810){
                updateFreq(955);
      }
      else{
          updateFreq(0);
      }
  }
}

int smooth_adc(void){
   int sum = 0;
   int i;
   for(i = 0; i < 16; i++){
     sum += poll_ADC();
   }
   return (sum/16);
}
