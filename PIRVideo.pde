//Lukas V. Dagilis
//www.lvdagilis.com
//2021 March 23rd

//NDG PIR Video -- v1.00.0

//PAST BUGS:
// 1. FIXED++ (ONLY SOLVED BY PI.PROCESSING.ORG raspbian image)
//    Video does not play with GLVideo library
// 2. FIXED++ Video laggy with processing.video* library
// 3. FIXED++ (not sensor/GPIO related) 
//    PIR sensor does not send high/low to sketch

//A polling-based solution to check for motion via PIR sensor (on GPIO pin 21), and play/pause a video based on the movement
//There is an added delay to pausing the video when motion is no longer detected. As this code was meant to be used for an installation in a gallery, and each sensor has it's own issues - a software delay was needed
//The delay can be changed by changing the "wait" int. 


//To-do:
//1. DONE++ Implement a config file, so that once exported - values can be changed (up+down arrow keys to change timer)
//2. DONE++ add debug mode for installation (pressing a button or key would trigger a new screen with:
//   DONE++a. video in corner
//   DONE++b. playback status
//   DONE++c. status of movement (detected or not)
//   DONE++d. status of delay (in case movement no longer detected - how long left until video pauses)
//   DONE++e. allow seeing set values, and to change them. (up+down arrow keys to change timer)

//
//
//

import gohai.glvideo.*;
import processing.io.*;
import java.awt.AWTException;
import java.awt.Robot;

Robot robby;

String[] config;
String name;

GLMovie movie;
boolean playing = false;

//Currently defaults to debug ON
boolean d = false;

//storing the latest received inputs from the GPIO pin in a buffer.
//Only need two values in the current implementation
//Can be used to negate false-positives if needed (code not supplied)
int value = 0;
int[] values;
int buffer = 3;
//Software-based timer for how long to wait once motion disappears to disable the video playback
//necessary as people are likely to sit down to view the installation
float timer1, timer2, timerD;
float delayTime = 5000; 

void setup() {
  //size(1280, 720, P2D);
  fullScreen(P2D);
  values = new int[buffer];
  GPIO.pinMode(21, GPIO.INPUT);
  config = loadStrings("config.txt");
    delayTime = float(config[0]);
  if (config.length>1) {
    name = config[1];
  } else { 
    name = "movie.mp4";
  }

  movie = new GLMovie(this, "movie.mp4");
  movie.loop();
  value = 0;
  background(0);
  timer1 = 0;
  timer2 = timer1+delayTime;
  noCursor();
  
  try{
    robby = new Robot();
  }
  catch (AWTException e){
   println("Robot class not supported by your system!"); 
   exit();
 }
}

void draw() {
  //Default video check for GLVideo - run every frame.
  read();
  //Since by default we expect no motion - we also pause the video at the first frame
  //Only run the 1st frame
  prep();
  //Checking the state of GPIO pin 21, where the PIR sensor is connected
  value = GPIO.digitalRead(21);
  //Send the GPIO pin value to our buffer
  buffer(value);
  //Check if we need to pause/play the video
  checkToggle();    
  //Show the video
  movie();
}
void read() {

  if (movie.available()) {
    movie.read();
  }
}
void prep() {
  if (frameCount<10) {
    movie.loop();
    image(movie, 0, 0, width, height);
    movie.pause();
    robby.mouseMove(width,height);
  }
}

void movie() {
  if (d) { 
    debug();
  } else {
    //Only need to update the image if we are playing the video.
    //if not playing - it should still be showing last frame, since we don't use background() every frame
    //so should be OK to save resources this way
    if (playing) {
      image(movie, 0, 0, width, height);
    }
  }
}


void checkToggle() {
  if (values[0] != values[1]) {
    if (value==1) {
      toggleVideo(true);
    } else if (value==0) {
      resetTimer();
    }
  }
  if (playing && checkTimer()==true && value==0 ) {
    toggleVideo(false);
  }
  if (value==1) {
    resetTimer();
  }
}

void toggleVideo(boolean b) {
  if (!b) {
    movie.pause();
    playing=false;
    println("Video stopped!");
  } else {
    movie.loop();
    playing = true;
    println("Video resumed!");
  }
}

void buffer(int val) {
  for (int i = values.length-1; i>0; i--) {
    values[i]=values[i-1];
  }
  values[0] = val;
}

void resetTimer() {
  timer1=millis()+delayTime;
  timer2=timer1-millis();
}

boolean checkTimer() {
  boolean state;
  timer2=timer1-millis();
  if (timer2<0) {
    state=true;
  } else {
    state = false;
  }
  return state;
}

void debug() {
  float mappedTimer = map(timer2, delayTime, -10, 255, 0);
  fill(mappedTimer);
  rect(0, 0, width/2, height/2);
  if (value ==1) {
    noStroke();
    fill(255);
    rectMode(CORNER);
    rect(0, height/2, width, height);
    fill(0);
    dText();
  } else if (value==0) {

    fill(0);
    rect(0, height/2, width, height);
    fill(255);
    dText();
  }
  image(movie, width/2, 0, width/2, height/2);
}

void dText() {
  pushMatrix();
  translate(0, height/2);
  textSize(12);
  text("Motion: " + value, 10, 10);
  text("Playing: " + playing, 10, 20);
  text("Delay: " + (timer2), 10, 30);
  text("Movie available? " + movie.available(), 10, 40);
  text("Movie Duration: " +movie.duration(), 10, 50);
  text("Movie time: " + movie.time(), 10, 60);
  text("config time: " +  config[0], 10, 70);
  text("config movie name: " + config[1], 10, 80);
  popMatrix();
}

void keyPressed() {
  if (keyPressed && key == 'd') {
    d =! d;
    println("Debug is now " + d);
  }
  if (key == CODED) {
    if (keyCode ==UP) {
      delayTime=delayTime+1000;
      textSize(48);
      text("Delay increased to " + delayTime/1000 + " seconds", width/2, height/2);
    } else if (keyCode == DOWN) {
      if (delayTime>=1000) {
        delayTime=delayTime-1000;
        textSize(48);
        text("Delay decreased to " + delayTime/1000 + " seconds", width/2, height/2);
      }
    }
    config[0] = str(delayTime);
    saveStrings(dataPath("config.txt"), config);
    resetTimer();
  }
}

void stop() {
  movie.dispose();
}
