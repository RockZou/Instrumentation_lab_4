#define bufferVolume 100
//bufferVolume represents how many measurements we take to be averaged
//for each reading

//the buffer stores the values generated within the bufferVolume
float buffer[bufferVolume];

//the counter keeps track of the current reading's position within the 
//buffer volume cycle

int counter;

//full is a flag for whether there has been enough readings made to fill
//up the buffer volume at least once
int full;

//the sum of all the values inside the buffer, used to calculate the average
float sum;


void setup()
{
  pinMode(A0, INPUT);
  Serial.begin(9600);
  
  establishContact();
  
  //init
  counter=0;
  full=0;
  sum =0;  
}

void loop()
{
  //read from the analog pin for a value between 0-1023
  int reading= analogRead(A0);
  //convert that 0-1023 value into a 0-5V value
  float val = 5*reading/1023.0;
  
  //if there hasn't been enough readings to fill up the buffer yet, 
  //don't average, don't start counter
  if (full<bufferVolume)
  {
    buffer[full]= val;
    sum += val;
    full++;
  }
  //if there's has been enough readings as all elements for buffer
  else 
  {
    //takes out the old values 
    //and replace it with new values
    
    sum -=buffer[counter];
    buffer[counter]=val;
    sum +=buffer[counter];
    
    //to calculate the average of all the values in the buffer
    float avg = sum/(1.0*bufferVolume);
    
    //this is a "rotating pointer" that takes out the old values 
    //and replace it with new values
    counter++;
    
    //when a buffer cycle is completed
    if (counter==bufferVolume)
    {
      //reset the counter when it reaches the last in the buffer volume
      counter = 0;
      //only print out the averaged value after a complete buffer 
      //session is finished.
      if (Serial.available() > 0) {
        
        int inByte = Serial.read();
    
        Serial.println(avg);
      }
    }
  }
  
  delay(5);//make a measurement every 5 miliseconds.
}


void establishContact() {
 while (Serial.available() <= 0) {
      Serial.println('A');   // send a capital A
      delay(300);
  }
}


