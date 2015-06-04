// By Jukniz(Chin Ho)

import processing.video.*;
import ddf.minim.*;
import java.util.*;
// Variable for capture device
Capture video;
// Previous Frame
PImage wastedImg;
PImage prevFrame;
PImage blackwhiteFrame;
PImage fondoMenu;
boolean locked = false;
Timer timerProfessor;
PImage imgProfessor;
ArrayList<PImage> listImgNoSeek;
ArrayList<RectButton> buttonList;
PImage seeking;
PImage rekt;
// How different must a pixel be to be a "motion" pixel
float threshold = 20;
float tol=0.10;
color currentcolor;
boolean catched = false;
boolean motion = false;
boolean gameOn;
int timeScore = 0;
int tiempo;
int compt=0;
String menuTitle;
AudioPlayer music;
AudioPlayer wastedSound;
AudioPlayer pressSound;



ScoreLabel scoreLabel;
AudioPlayer callad;  
Minim minim;
CamOn camon;
CamOff camoff;

void setup() {
  size(640, 480);
    smooth();
    menuTitle="Selecciona tu professor:";
    fondoMenu=loadImage("background.jpg");

  color baseColor = color(102);
  gameOn=false;
  currentcolor = baseColor;
  buttonList=new ArrayList<RectButton>();
  buttonList.add(new RectButton(175,180,300,60, color(0, 0, 0, 180), color(0, 0, 0), "Oscar Garcia",   "oscar/"));
  buttonList.add(new RectButton(175,280,300,60, color(0, 0, 0, 180), color(0, 0, 0), "German Sanchez", "german/"));
  buttonList.add(new RectButton(175,380,300,60, color(0, 0 ,0, 180), color(0, 0, 0), "Jordi Radev", "radev/"));
  
  wastedImg=loadImage("wasted.png");

  timerProfessor= new Timer(1000);
  timerProfessor.start();
  
  frameRate(30);
  textSize(16);
  if (video == null) {
    video = new Capture(this, width, height, 30);
    // Create an empty image the same size as the video
    prevFrame = createImage(video.width, video.height, RGB);
    blackwhiteFrame = createImage(video.width, video.height, RGB);
    video.start();
    
    scoreLabel = new ScoreLabel(0);
   

  }
  
  else {
    video.stop();
    video = null;
    minim = null;

    callad = null;
    
    video = new Capture(this, width, height, 30);
    prevFrame = createImage(video.width, video.height, RGB);
    blackwhiteFrame = createImage(video.width, video.height, RGB);
    video.start();
    
    scoreLabel = new ScoreLabel(0);
    minim = new Minim(this);
    
  }
   if(minim == null){
    minim = new Minim(this);
    }
    
    if (callad==null) {
      callad = minim.loadFile("callad.mp3", 2048);
    }
    
     if (music==null) {
    music = minim.loadFile("jumper.mp3", 2048);
    music.play();
    music.loop();
  }
  
 if (wastedSound==null) {
      minim = new Minim(this);
      wastedSound = minim.loadFile("wasted.mp3", 2048);
    }
    
    if(pressSound==null){
      minim = new Minim(this);
      pressSound = minim.loadFile("pressSound.wav", 2048);
    }
  camon = new CamOn();
  camoff = new CamOff();
}

void draw() {
  if(!gameOn){
  background(currentcolor);
  image(fondoMenu,0,0);
 
  textAlign(CENTER, CENTER);
  fill(188,14,129);
  rect(120,65, 400,80);
  textSize(30);
  fill(255);
  text(menuTitle,width/2 , 100);
  textSize(16);
  textAlign(LEFT);
  
  
  
  for(RectButton rectButton : buttonList){
    rectButton.display();
    rectButton.update();
  }
  
  }else{
  timeScore = millis();
  motion=false;
  // Capture video
  if (video.available()) {
    // Save previous frame for motion detection!!
    prevFrame.copy(video, 0, 0, video.width, video.height, 0, 0, video.width, video.height); // Before we read the new frame, we always save the previous frame for comparison!
    prevFrame.updatePixels();
    video.read();
  }

  loadPixels();
  video.loadPixels();
  prevFrame.loadPixels();

  // Begin loop to walk through every pixel
  int pixchange = 0;
  for (int x = 0; x < video.width; x ++ ) {
    for (int y = 0; y < video.height; y ++ ) {

      int loc = x + y*video.width;            // Step 1, what is the 1D pixel location
      color current = video.pixels[loc];      // Step 2, what is the current color
      color previous = prevFrame.pixels[loc]; // Step 3, what is the previous color

      // Step 4, compare colors (previous vs. current)
      float r1 = red(current); 
      float g1 = green(current); 
      float b1 = blue(current);
      float r2 = red(previous); 
      float g2 = green(previous); 
      float b2 = blue(previous);
      float diff = dist(r1, g1, b1, r2, g2, b2);

      // Step 5, How different are the colors?
      // If the color at that pixel has changed, then there is motion at that pixel.
      if (diff > threshold) {
          pixchange++;
        // If motion, display black flipped

          blackwhiteFrame.pixels[(video.width - x - 1) + y*video.width] = color(0);
      } else {
        //If not, display white flipped
        blackwhiteFrame.pixels[(video.width - x - 1) + y*video.width] = color(255);
      }
    }
  }
  
  float percentage = (float)(pixchange) / ((float) (blackwhiteFrame.width) * (float)(blackwhiteFrame.height));
 
  if (percentage >= tol) {
    motion = true;
  } 

// flip video image
  for (int x = 0; x < video.width; x++) {
    // Begin loop for height 
    for (int y = 0; y < video.height; y++) {     
     pixels[y*video.width+x] = video.pixels[(video.width - x - 1) + y*video.width];
    // pixels[y*video.width+x] = blackwhiteFrame.pixels[y*video.width+x];
    }
  }

  updatePixels();

  if (!catched) {
    tiempo=millis();
    if (!camoff.isFinished){
       // System.out.println(" TREGUA ");
       
       if(camoff.remaining() == 1 && !callad.isPlaying()) {
         //System.out.println("Playing sound: shhhhhhhhh");
        
         callad.play();
         callad.rewind();
          music.pause();
       }
       
       if(timerProfessor.isFinished()){
         compt++;
         compt%=listImgNoSeek.size();
         timerProfessor.start();
       }
       
       image(listImgNoSeek.get(compt),540,380, 100, 100);
        camoff.update();
    }
  
    else if (!camon.isFinished) {
      //System.out.println(" TE MIRO !!! ");
      image(seeking,540,380, 100, 100);
      
      if (motion) {
        System.out.println(" -- PILLADO -- ");
        callad.pause();
        callad.rewind();
        music.pause();
        music.rewind();
        wastedSound.play();
        wastedSound.rewind();
        catched = true;
      }
      else camon.update();
    }
    
    else {
      //System.out.println(" << NUEVO CAM >> ");
      camoff = new CamOff();
      camon = new CamOn();
    }
    //println(percentage);
    if(percentage>tol){
    scoreLabel.score+=5*percentage;
    }
    scoreLabel.update();
    
}else{
    filter(GRAY);
    compt=0;
    image(wastedImg,160,-90);
    image(rekt,540,380, 100, 100);
    textSize(24);
    textAlign(CENTER);
    text("Press Enter to Restart", width/2, height-25);
    text("or press ESC to Exit", width/2, height-5);
    textAlign(LEFT);
    textSize(16);
    //ENTER
      if (keyPressed) {
        if (key == ENTER) {
          System.out.println("Enter pressed... ");
          catched = false;
          setup();
        }
        if (key == ESC) {
          System.exit(0);
        }  
      }
    
}
  }
}


void loadImgProfessor(String dir){
  pressSound.play();
    seeking=loadImage(dir+"Front.jpg");
  rekt=loadImage(dir+"Angry.jpg");
  listImgNoSeek=new ArrayList<PImage>();
  listImgNoSeek.add(loadImage(dir+"Right.jpg"));
  listImgNoSeek.add(loadImage(dir+"Left.jpg"));
    imgProfessor= listImgNoSeek.get(0);
    //println(dir);
       gameOn=true;
}

class CamOn {
  boolean isFinished;
  int seconds = 0;
  Timer timer;
  
  void randomTime() {
    seconds = (int)random(5.0,11); 
    if(!music.isPlaying()){
       music.play();
       }
  }
  
  CamOn() {
    isFinished = false;
    randomTime();
    timer = new Timer(1000);
    timer.start();
  }
  
  void update() {
    if (timer.isFinished()) {
      seconds--;
      timer.start();
    }
    if (seconds<=0) {
      isFinished=true;
    }
    text(" ",500, 30); //No avisa que te esta mirando.
  }
    
}

class CamOff {
  boolean isFinished;
  int seconds = 0;
  Timer timer;
  
  void randomTime() {
    seconds = (int)random(5.0,11); // Cambiar si quieres el máximo (máx + 1)
  }
  
  CamOff() {
    isFinished = false;
    randomTime();
    timer = new Timer(1000);
    timer.start();
  }
  
  void update() {
    if (timer.isFinished()) {
      seconds--;
      timer.start();
    }
    if (seconds<=0) {
      isFinished=true;
    }
    fill(255);
    //text("Can't see you: "+seconds, 500, 30); //Avisa que no te està viendo.
  }
  
  int remaining() {
    return seconds;
  }

    
}

class ScoreLabel {
  float score;
  ScoreLabel(float score) {
    this.score = score;
  }

  void update() {
    fill(255);
    text("Score: "+floor(score), 20, 30);
  }
}

class Timer {

  int savedTime; // When Timer started
  int totalTime; // How long Timer should last

  Timer(int tempTotalTime) {
    totalTime = tempTotalTime;
  }

  // Starting the timer
  void start() {
    // When the timer starts it stores the current time in milliseconds.
    savedTime = millis();
  }
  
  // The function isFinished() returns true if 5,000 ms have passed. 
  // The work of the timer is farmed out to this method.
  boolean isFinished() { 
    // Check how much time has passed
    int passedTime = millis()- savedTime;
    if (passedTime > totalTime) {
      return true;
    } else {
      return false;
    }
  }
}



class Button
{
  int x, y;
  int xsize, ysize;
  color basecolor, highlightcolor;
  color currentcolor;
  boolean over = false;
  boolean pressed = false;   
  String text;
  String dirButton;

  void update() 
  {
    if(over()) {
      currentcolor = highlightcolor;
    } else {
      currentcolor = basecolor;
    }
     if(pressed() && mousePressed){
       loadImgProfessor(dirButton);
     }
  }

  boolean pressed() 
  {     
    if(over) {
      locked = true;
      return true;
    } else {
      locked = false;
      return false;
    }    
  }

  boolean over() 
  { 
    return true; 
  }

  boolean overRect(int x, int y, int width, int height) 
  {
    if (mouseX >= x && mouseX <= x+width && mouseY >= y && mouseY <= y+height) {
      return true;
    } else {
      return false;
    }
  }

  boolean overCircle(int x, int y, int diameter) 
  {
    float disX = x - mouseX;
    float disY = y - mouseY;
    if(sqrt(sq(disX) + sq(disY)) < diameter/2 ) {
      return true;
    } else {
      return false;
    }
  }
}

class RectButton extends Button
{
  RectButton(int ix, int iy, int xsize, int ysize, color icolor, color ihighlight, String text, String dirButton) 
  {
    this.x = ix;
    this.y = iy;
    this.xsize = xsize;
    this.ysize = ysize;
    this.basecolor = icolor;
    this.highlightcolor = ihighlight;
    this.currentcolor = basecolor;
    this.text=text;
    this.dirButton = dirButton;
  }

  boolean over() 
  {
    if( overRect(x, y, xsize, ysize) ) {
      over = true;
      return true;
    } 
    else {
      over = false;
      return false;
    }
  }

  void display() 
  {
    stroke(255);
    fill(currentcolor);
    rect(x, y, xsize, ysize);
     fill(255);
     textSize(20);
     textAlign(CENTER, CENTER);
    text(text,x+xsize/2, y+ysize/2);
    textAlign(LEFT);
    textSize(16);
  }
}
