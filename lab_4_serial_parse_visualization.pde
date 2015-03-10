/** 
Based on Processing Example
 * Serial Call-Response 
 * by Tom Igoe.  
**/

import processing.serial.*;

import controlP5.*;

ControlP5 cp5;


DropdownList d1;
int dropDownNum;

Button connect;

int rectWidth = 5;

Serial myPort;                       // The serial port
FloatList buffer = new FloatList(100);    // Where we'll put what we receive
int bufferCount = 0;                 // A count of how many bytes we receive
boolean firstContact = false;        // Whether we've heard from the microcontroller

float inFloat=0.0;

int state =0;

void controlP5_setup(){
  cp5 = new ControlP5(this);
  // create a DropdownList
  d1 = cp5.addDropdownList("myList-d1")
          .setPosition(100, 50)
          .setSize(200,100)
          ;
  connect = cp5.addButton("connect")
               .setPosition(330,20)
               .setSize(50,30);
  customize(d1); // customize the first list
  d1.setIndex(0);
  dropDownNum=0;
}

void customize(DropdownList ddl) {
  // a convenience function to customize a DropdownList
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(25);
  ddl.setBarHeight(25);
  ddl.captionLabel().set("dropdown");
  ddl.captionLabel().style().marginTop = 3;
  ddl.captionLabel().style().marginLeft = 3;
  ddl.valueLabel().style().marginTop = 3;
  for (int i=0;i<Serial.list().length;i++) {
    ddl.addItem(Serial.list()[i],i);
  }
  //ddl.scroll(0);
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
}

void controlEvent(ControlEvent theEvent) {
  // DropdownList is of type ControlGroup.
  // A controlEvent will be triggered from inside the ControlGroup class.
  // therefore you need to check the originator of the Event with
  // if (theEvent.isGroup())
  // to avoid an error message thrown by controlP5.

  if (theEvent.isGroup()) {
    // check if the Event was triggered from a ControlGroup
    println("event from group : "+theEvent.getGroup().getValue()+" from "+theEvent.getGroup());
    dropDownNum = int(theEvent.getGroup().getValue());
    println("dropDownNum is", dropDownNum);
  } 
  else if (theEvent.isController()) {
    println("event from controller : "+theEvent.getController().getValue()+" from "+theEvent.getController());

    if (theEvent.getController()==connect){
      makeConnection();
    }
  }
}

void setup() {
  size(500, 300);  // Stage size
  noStroke();      // No border on the next thing drawn

  controlP5_setup();

  for (int i =0;i<100;i++)
  buffer.set(i,0);

}

void draw() {
  background(0);
  
  switch (state)
  {
    case 0:
      createUI();
    break;
    case 1:
      visualization();
    break;
  }
}

void visualization()
{ 
  for (int i =0;  i<100;i++)
  {
    float rectLength = map(buffer.get(i),0,5.0,0,height);
    rect(width-rectWidth*i,height-rectLength,rectWidth,rectLength);
  }
}

void createUI()
{
}

void makeConnection()
{
  // I know that the first port in the serial list on my mac
  // is always my  FTDI adaptor, so I open Serial.list()[0].
  // On Windows machines, this generally opens COM1.
  // Open whatever port is the one you're using.
  String portName = Serial.list()[dropDownNum];
  myPort = new Serial(this, portName, 9600);
  println("connection made");
  state = 1;
}

String inString ="";

void serialEvent(Serial myPort) {
  
  // read a byte from the serial port:
  int inByte = myPort.read();
  char inChar = char(inByte);

  // if this is the first byte received, and it's an A,
  // clear the serial buffer and note that you've
  // had first contact from the microcontroller. 
  // Otherwise, add the incoming byte to the array:
  if (firstContact == false) {
    println("first contacting");
    println("data is,", inChar);
     if (inChar == 'A') 
     {
       println("I start recording");
        myPort.clear();          // clear the serial port buffer
        firstContact = true;     // you've had first contact from the microcontroller
        myPort.write('A');       // ask for more
        inString = "0";
      }
  }
  else {
    if (inChar!=10)
    {
      inString+=inChar;
    }
    else
    {
      inFloat = float(inString);
      
      buffer.remove(0);
      buffer.append(inFloat);
      
      println(inFloat);
      inString = "";
    }
    myPort.write('A');
    }
}
