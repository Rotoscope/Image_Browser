/******
  File: Image Browser
  By: Stanley Seeto
  Date: 9/29/14
  
  Compile: Processing 2.2.1 run button
  Usage: Processing 2.2.1 run button
  System: used Windows 7
  
  Description: image browser; left & right scroll;
    up opens & down minimizes; > < skips to next set
    displays image in the data folder
    Images slide on certain conditions
    Saves and show tags and one box tag

*******/
import ddf.minim.*;
import controlP5.*;
import java.util.*;
import oscP5.*;
import netP5.*;

PImage[] img;
String[] filenames, existingTags, boxTags;
String tagInBox;
int cur, left, mode, vel, isTransition;
int pixelShift;    //keeps track of the transition pixel shifts
boolean boxTagMode, tagsLoaded, hasBoxTag;
int boxX, boxY, boxW, boxH; //dimension of the tag box
Minim minim;
AudioPlayer shortP, longP;  //long and short audio for button pushing
ControlP5 cp5;
Textarea existTags, newTags;
ArrayList<String> tagList;
OscP5 oscP5;
int myListeningPort = 32000;
int myBroadcastPort = 12000;

void setup() {
  size(800, 600);
  background(45, 160, 220);
  if(frame != null) frame.setResizable(true);
  PFont font = createFont("arial",20);
  
  /* initialize the starting mode and location of the pointers to the images */
  mode = 0;
  cur = 0;
  left = 0;
  vel = 5;
  pixelShift = 0;
  isTransition = 0;
  boxTagMode = false;
  boxTags = new String[5];
  tagInBox = "";
  tagsLoaded = false;    //does not constantly load tags
  hasBoxTag = false;
  resetBoxTags();
  
  String path = sketchPath;
  filenames = listFileNames(path + "\\data");
  tagList = new ArrayList<String>();
  
   /* Load all image files */ 
  if(filenames.length == 0) {  //empty folder
    textSize(16);
    fill(50);
    text("No images in data folder", 50, 102);  
  } else {
    img = new PImage[filenames.length];
    for(int i = 0; i < filenames.length; i++) {
      img[i] = loadImage(filenames[i]);
    }
  }
  
  minim = new Minim(this);
  shortP = minim.loadFile("tap_short.wav");
  longP = minim.loadFile("tap.wav");

  cp5 = new ControlP5(this);  
  cp5.addButton("save_tags")
     .setBroadcast(false)
     .setValue(30)
     .setPosition(665,715)
     .setSize(100,20)
     .setBroadcast(true)
     .setVisible(false);
     
  cp5.addButton("tag_box_in_image")
     .setBroadcast(false)
     .setValue(20)
     .setPosition(665,690)
     .setSize(100,20)
     .setBroadcast(true)
     .setVisible(false);
     
  cp5.addTextfield("tags")
     .setPosition(25,695)
     .setSize(625,40)
     .setFont(font)
     .setFocus(true)
     .setColor(color(255,0,0))
     .setVisible(false);
     
  newTags = cp5.addTextarea("newtags")
               .setPosition(25,600)
               .setSize(350,70)
               .setFont(createFont("arial",12))
               .setLineHeight(14)
               .setColor(color(0))
               .setColorBackground(color(255,255))
               .setColorForeground(color(255,100))
               .setVisible(false);
  
  existTags = cp5.addTextarea("existtags")
                 .setPosition(400,600)
                 .setSize(350,70)
                 .setFont(createFont("arial",12))
                 .setLineHeight(14)
                 .setColor(color(0))
                 .setColorBackground(color(255))
                 .setColorForeground(color(255,100))
                 .setVisible(false);
  
  textFont(font);
  
  oscP5 = new OscP5(this, myListeningPort);
}

void draw() {
  if(img != null) drawImage();
}

void drawImage() {
  background(45, 160, 220);
  if(isTransition == 0) {
    if(mode == 0)
      drawThumbs(left, 0);
    else if(mode == 1) {
      singleImage(cur, 0);
    }
    showTags();
  } else {
    if(isTransition < 0) {    //transition to the left
      if(mode == 1) {
        singleImage((cur + 1) % img.length, pixelShift);
        singleImage(cur, pixelShift - 800);
      } else if(mode == 0) {
        drawThumbs((left + 5) % img.length, pixelShift);
        drawThumbs(left, pixelShift - 800);
      }
      pixelShift += vel;
    } else if(isTransition > 0) {    //transition to the right
      if(mode == 1) {
        singleImage((cur + img.length - 1) % img.length, pixelShift);
        singleImage(cur, pixelShift + 800);
      } else if(mode == 0) {
        drawThumbs((left + img.length - 5) % img.length, pixelShift);
        drawThumbs(left, pixelShift + 800);
      }
      pixelShift -= vel;
    }
    if(pixelShift >= 800 || pixelShift <= -800) {
      pixelShift = 0;
      isTransition = 0;
    }
  }
}

void drawThumbs(int index, int m) {
  int k;
  float xStart = m + 50;
  
  /* border for current image */
  if(index == left) {    //without this the transitions create two borders
    fill(230, 165, 70);
    int loc = cur - left;
    if(loc < 0) loc = loc + img.length;
    rect(loc * 150 + 40 + m, 240, 120, 120);
  }
  
  int j = index;
  int max = 5;
  if(img.length < 5) max = img.length;
  for(int i = 0; i < max; i++) {
    k = tResChk(img[j]);
    if(k == -1 || k == 0) {    //scale to adjust the width of image
      float wid = img[j].width * 100. / img[j].height;
      image(img[j], (100. - wid) / 2. + xStart, 250, wid, 100);
    } else if(k == 1) {        //scale to adjust the height of image
      float hei = img[j].height * 100. / img[j].width;
      image(img[j], xStart, (100 - hei) / 2 + 250, 100, hei);  
    }
    j = (j + 1) % img.length;
    xStart += 150;   
  }
}

void singleImage(int index, int k) {
  int i = sResChk(img[index]);
  if(i == -1 || i == 0) {
    float wid = img[index].width * 500. / img[index].height;
    image(img[index], k + (700. - wid) / 2. + 50., 50, wid, 500);
  } else if(i == 1) {
    float hei = img[index].height * 700 / img[index].width;
    image(img[index], k + 50, (500. - hei) / 2. + 50., 700, hei);
  }
}
  
void mousePressed() {
  if(mouseY >= 250 && mouseY <= 350 && mode == 0) {
    if(mouseX >= 50 && mouseX <= 150) {
      cur = left;
      mode = 1;
    } else if(mouseX >= 200 && mouseX <= 300) {
      cur = left + 1;
      mode = 1;
    } else if(mouseX >= 350 && mouseX <= 450) {
      cur = left + 2;
      mode = 1;
    } else if(mouseX >= 500 && mouseX <= 600) {
      cur = left + 3;
      mode = 1;
    } else if(mouseX >= 650 && mouseX <= 750) {
      cur = left + 4;
      mode = 1;
    }
    if(mode == 1) shortP.play();
  }
  if(boxTagMode && mouseX >= 50 && mouseX <= 750 && mouseY >= 50 && mouseY <= 550) {
    boxX = mouseX;
    boxY = mouseY;
  }
}

void mouseDragged() {
  if(boxTagMode) {
    int k = sResChk(img[cur]);
    if(k == -1 || k ==0) {
      int wid = img[cur].width * 500 / img[cur].height;
      if(mouseX >= (700 - wid) / 2 + 50 && mouseX <= (700 + wid) / 2 + 50 && mouseY >= 50 && mouseY <= 550) {
        boxW = mouseX;
        boxH = mouseY;
      } else if(mouseX < (700 - wid) / 2 + 50)
        boxW = (700 - wid) / 2 + 50;
      else if(mouseX > (700 + wid) / 2 + 50)
        boxW = (700 + wid) / 2 + 50;
      else if(mouseY < 50)
        boxH = 50;
      else if(mouseY > 550)
        boxH = 550;
    } else if(k == 1) {
      int hei = img[cur].height * 700 / img[cur].width;
      if(mouseX >= 50 && mouseX <= 750 && mouseY >= (500 - hei) / 2 + 50 && mouseY <= (500 + hei) / 2 + 50) {
        boxW = mouseX;
        boxH = mouseY;
      } else if(mouseX < 50)
        boxW = 50;
      else if(mouseX > 750)
        boxW = 750;
      else if(mouseY < (500 - hei) / 2 + 50)
        boxH = (500 - hei) / 2 + 50;
      else if(mouseY > (500 + hei) / 2 + 50)
        boxH = (500 + hei) / 2 + 50;
    }
    boxTags[1] = "x:" + boxX;
    boxTags[2] = "y:" + boxY;
    boxTags[3] = "w:" + boxW;
    boxTags[4] = "h:" + boxH;
  }
}

void mouseReleased() {
}

void keyPressed() {
  if(isTransition == 0) {  //keys only work if it is not in a transition phase
    if(key == CODED) {
      if(keyCode == UP && mode == 0) {
        mode = 1;
        frame.setSize(800,800);
        shortP.play();
      } else if(keyCode == DOWN && mode == 1) {
        if(img.length > 5) left = (cur + img.length - 2) % img.length;
        mode = 0;
        frame.setSize(800,600);
        shortP.play();
      } else if(keyCode == LEFT) {
        if(img.length > 5 && cur == left) {  //hit border so shift
          left = (left + img.length - 5) % img.length;
          isTransition = -1;
        }
        if(mode == 1) isTransition = -1;  //always shift when moved in single image
        cur = (cur + img.length - 1) % img.length;
        if(isTransition == 0) shortP.play();
        else longP.play();
        
        tagsLoaded = false;
        resetBoxTags();
      } else if(keyCode == RIGHT) {
        if(img.length > 5 && cur == (left + 4) % img.length) {  //hit border so shift
          left = (left + 5) % img.length;
          isTransition = 1;
        }
        if(mode == 1) isTransition = 1;  //always shift when moved in single image
        cur = (cur + 1) % img.length; 
        if(isTransition == 0) shortP.play();
        else longP.play();
        
        tagsLoaded = false;
        resetBoxTags();
      }
    }
    if((key == '>' || key == '.') && mode == 0) {
      isTransition = 1;
      cur = (cur + 5) % img.length;
      left = (left + 5) % img.length;
      longP.play();
      tagsLoaded = false;
    }
    if((key == '<' || key == ',') && mode == 0) {
      isTransition = -1;
      cur = (cur + img.length - 5) % img.length;
      left = (left + img.length - 5) % img.length;
      longP.play();
      tagsLoaded = false;
    }
    shortP.rewind();
    longP.rewind();
  }
}

//This function checks the ratio of the image resolution for proper scaling for single image
int sResChk(PImage aImg) {
  if((double)aImg.width/aImg.height > 1.4) //700x500 single image display
    return 1;
  else if((double)aImg.width/aImg.height < 1.4)
    return -1;
  else 
    return 0;
}

//resolution check for thumbnails
int tResChk(PImage aImg) {
  if((double)aImg.width/aImg.height > 1.0) //100x100 thumbnail space
    return 1;
  else if((double)aImg.width/aImg.height < 1.0)
    return -1;
  else 
    return 0;
}

/*  //debugging code to see what event happened
public void controlEvent(ControlEvent theEvent) {
  String eventName = theEvent.getController().getName();
  println(eventName);
}
*/

public void save_tags(int theValue) {
  String fname = getCurFileName() + ".txt", t = "";
  String newTags[];
  ArrayList<String> joined = new ArrayList<String>();
  
  if(!tagList.isEmpty()) {
    newTags = tagList.toArray(new String[tagList.size()]);
    joined.addAll(Arrays.asList(newTags));
  }
  
  if(existingTags != null)
    joined.addAll(Arrays.asList(existingTags));

  //remove duplicate tags
  LinkedHashSet hs = new LinkedHashSet();
  hs.addAll(joined);
  joined.clear();
  joined.addAll(hs);
   
  //replace old box tag with new one   
  if(!boxTags[0].isEmpty()) {
    joined.remove(boxTags[0]);
    t = boxTags[0]+" "+boxTags[1]+" "+boxTags[2]+" "+boxTags[3]+" "+boxTags[4];
    joined.add(t);
  } else if(hasBoxTag == true) {
    joined.remove(tagInBox);
    t = tagInBox+" x:"+boxX+" y:"+boxY+" w:"+boxW+" h:"+boxH;
    joined.add(t);
  }

  saveStrings(fname, joined.toArray(new String[joined.size()]));
  tagList.clear();
  
  resetBoxTags();
  tagsLoaded = false;
}

/* add strings after entered in textfield */
public void tags(String theText) {
  if(boxTagMode) {
    boxTags[0] = theText;
    boxTagMode = false;
  }
  if(!tagList.contains(theText)) {
    tagList.add(theText);
  }
}

void showTags() {
  if(mode == 0) {
    cp5.controller("save_tags").setVisible(false);
    cp5.controller("tag_box_in_image").setVisible(false);
    cp5.controller("tags").setVisible(false);
    newTags.setVisible(false);
    existTags.setVisible(false);
  } else {
    cp5.controller("save_tags").setVisible(true);
    cp5.controller("tag_box_in_image").setVisible(true);
    cp5.controller("tags").setVisible(true);
    newTags.setVisible(true);
    existTags.setVisible(true);
    if(!tagsLoaded) loadTags();
    showCurTags();
    showNewTags();
    showBoxTag();
  }
}

void loadTags() {
  String fname = getCurFileName() + ".txt", possibleBoxTag;
  String[] tempBoxTags;
  
  existingTags = loadStrings(fname);
  
  if(existingTags != null && existingTags.length != 0) {
    possibleBoxTag = existingTags[existingTags.length - 1];
    tempBoxTags = possibleBoxTag.split(" ");
    if(tempBoxTags.length == 5 && tempBoxTags[1].startsWith("x:") && tempBoxTags[2].startsWith("y:") && 
       tempBoxTags[3].startsWith("w:") && tempBoxTags[4].startsWith("h:")) {
      tempBoxTags[1] = tempBoxTags[1].replace("x:", "");
      tempBoxTags[2] = tempBoxTags[2].replace("y:", "");
      tempBoxTags[3] = tempBoxTags[3].replace("w:", "");
      tempBoxTags[4] = tempBoxTags[4].replace("h:", "");
      if(isInt(tempBoxTags[1]) && isInt(tempBoxTags[2]) && isInt(tempBoxTags[3]) && isInt(tempBoxTags[4])) {
        tagInBox = tempBoxTags[0];
        boxX = parseInt(tempBoxTags[1]);
        boxY = parseInt(tempBoxTags[2]);
        boxW = parseInt(tempBoxTags[3]);
        boxH = parseInt(tempBoxTags[4]);
        hasBoxTag = true;
        existingTags[existingTags.length - 1] = tagInBox;
      }
    }
  }
  tagsLoaded = true;
}

void showCurTags() {
  String display;
  String[] tempBoxTags;
  
  display = "Existing tags:\n";

  if(existingTags != null) { 
    for(String s: existingTags)
      if(!s.isEmpty()) display = display + s + "\n";
  }
  existTags.setText(display);
}

void showNewTags() {
  String display = "New tags:\n";
  if(tagList != null && !tagList.isEmpty()) {
    String tag[] = tagList.toArray(new String[tagList.size()]);
    for(String s: tag)
      display = display + s + "\n";
  }
  newTags.setText(display);
}

void showBoxTag() {
  if(boxW != 0 && boxH != 0) {
    //draw the box
    stroke(204,102,0);
    line(boxX, boxY, boxW, boxY);
    line(boxX, boxY, boxX, boxH);
    line(boxX, boxH, boxW, boxH);
    line(boxW, boxY, boxW, boxH);
    if(((mouseX > boxX && mouseX < boxW) || (mouseX < boxX && mouseX > boxW)) && 
       ((mouseY > boxY && mouseY < boxH) || (mouseY < boxY && mouseY > boxH)) && 
       tagInBox != null) {
      if(!boxTagMode) {
        textSize(16);
        fill(240,50,30);
        text(tagInBox, mouseX, mouseY);
      } else if(boxTagMode) {
        textSize(16);
        fill(240,50,30);
        text("Enter box tag", mouseX, mouseY);      
      }
    }
  }
}


void resetBoxTags() {
  for(int k = 0; k < boxTags.length; k++)
    boxTags[k] = "";
  boxX = 0;
  boxY = 0;
  boxW = 0;
  boxH = 0;
  tagInBox = "";
  hasBoxTag = false;
}

public void tag_box_in_image(int theValue) {
  boxTagMode = !boxTagMode;
}

String getCurFileName() {
  String[] s = split(filenames[cur], '.');
  return s[0];
}

boolean isInt(String s) {
  try { 
    Integer.parseInt(s); 
  } catch(NumberFormatException e) { 
    return false; 
  }
  return true;
}

/*****************
  The bottom portion is taken from the examples
  *******************/
  
// This function returns all the files in a directory as an array of Strings  
String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    // If it's not a directory
    return null;
  }
}
