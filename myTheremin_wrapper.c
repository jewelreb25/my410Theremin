extern int myTheremin(void);
extern int poll_ADC(void);
extern int updateFreq(int);

int main(){
  myTheremin();
  while(1){
  long int valueRead= poll_ADC();
      if(valueRead>0&& valueRead<600){
          updateFreq(318);
      }
      else if(valueRead>600&& valueRead<1200){
                updateFreq(357);
      }
      else if(valueRead>1200&& valueRead<1800){
                updateFreq(379);
      }
      else if(valueRead>1800&& valueRead<2400){
                updateFreq(425);
      }
      else if(valueRead>2400&& valueRead<3000){
                updateFreq(477);
      }
      else if(valueRead>3000&& valueRead<3600){
                updateFreq(506);
      }
      else if(valueRead>3600&& valueRead<4095){
                updateFreq(567);
      }
      else if(valueRead>4200&& valueRead<4500){
                updateFreq(637);
      }
      else if(valueRead>2000&& valueRead<3000){
                updateFreq(715);
      }
      else{
          updateFreq(955);
      }
  }
}
