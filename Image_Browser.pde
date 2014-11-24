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

*******/
import ddf.minim.*;
import controlP5.*;
import java.util.*;

PImage[] img;
String[] filenames, existingTags;
int cur, left, mode, vel, isTransition;
int pixelShift;    //keeps track of the transition pixel shifts
Minim minim;
AudioPlayer shortP, longP;  //long and short audio for button pushing
ControlP5 cp5;
Textarea existTags, newTags;
ArrayList<String> tagList;

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
     .setPosition(665,695)
     .setSize(100,40)
     .setBroadcast(true);
     
  cp5.addTextfield("tags")
     .setPosition(25,695)
     .setSize(625,40)
     .setFont(font)
     .setFocus(true)
     .setColor(color(255,0,0));
     
  newTags = cp5.addTextarea("newtags")
               .setPosition(25,600)
               .setSize(350,70)
               .setFont(createFont("arial",12))
               .setLineHeight(14)
               .setColor(color(0))
               .setColorBackground(color(255,255))
               .setColorForeground(color(255,100));
  
  existTags = cp5.addTextarea("existtags")
                 .setPosition(400,600)
                 .setSize(350,70)
                 .setFont(createFont("arial",12))
                 .setLineHeight(14)
                 .setColor(color(0))
                 .setColorBackground(color(255))
                 .setColorForeground(color(255,100));
  
  textFont(font);
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
      showTags();
    }
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
    k = resChk(img[j]);
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
  int i = resChk(img[index]);
  if(i == -1 || i == 0) {
    float wid = img[index].width * 500. / img[index].height;
    image(img[index], k + (700. - wid) / 2. + 50., 50, wid, 500);
  } else if(i == 1) {
    float hei = img[index].height * 700 / img[index].width;
    image(img[index], k + 50, (500 - hei) / 2. + 50., 700, hei);
  }
}
  
void mousePressed() {
  if(mouseY >= 250 && mouseY <= 350 && mode == 0) {
    if(mouseX >= 50 && mouseX <= 150) {
      cur = left;
      mode = 1;
    } else if(mouseX >= 200 && mouseX <= 300) {
      cur = (left + 1) % img.length;
      mode = 1;
    } else if(mouseX >= 350 && mouseX <= 450) {
      cur = (left + 2) % img.length;
      mode = 1;
    } else if(mouseX >= 500 && mouseX <= 600) {
      cur = (left + 3) % img.length;
      mode = 1;
    } else if(mouseX >= 650 && mouseX <= 750) {
      cur = (left + 4) % img.length;
      mode = 1;
    }
    if(mode == 1) {
      shortP.play();
      frame.setSize(800,800);
      shortP.rewind();
    }
  }
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
      } else if(keyCode == RIGHT) {
        if(img.length > 5 && cur == (left + 4) % img.length) {  //hit border so shift
          left = (left + 5) % img.length;
          isTransition = 1;
        }
        if(mode == 1) isTransition = 1;  //always shift when moved in single image
        cur = (cur + 1) % img.length; 
        if(isTransition == 0) shortP.play();
        else longP.play();
      }
    }
    if((key == '>' || key == '.') && mode == 0) {
      isTransition = 1;
      cur = (cur + 5) % img.length;
      left = (left + 5) % img.length;
      longP.play();
    }
    if((key == '<' || key == ',') && mode == 0) {
      isTransition = -1;
      cur = (cur + img.length - 5) % img.length;
      left = (left + img.length - 5) % img.length;
      longP.play();
    }
    shortP.rewind();
    longP.rewind();
  }
}

//This function checks the ratio of the image resolution for proper scaling
int resChk(PImage aImg) {
  if((double)aImg.width/aImg.height > 1.0) 
    return 1;
  else if((double)aImg.width/aImg.height < 1.0)
    return -1;
  else 
    return 0;
}

public void controlEvent(ControlEvent theEvent) {
  println(theEvent.getController().getName());
}

public void save_tags(int theValue) {
  String fname = getCurFileName() + ".txt";
  String tags[] = tagList.toArray(new String[tagList.size()]);
  List<String> joined = new ArrayList<String>();
  if(existingTags != null)
    joined.addAll(Arrays.asList(existingTags));
  joined.addAll(Arrays.asList(tags));
  saveStrings(fname, joined.toArray(new String[joined.size()]));
  tagList.clear();
}

/* add strings after entered in textfield */
public void tags(String theText) {
  tagList.add(theText);
}

void showTags() {
  showCurTags();
  showNewTags();
}

void showCurTags() {
  String fname = getCurFileName() + ".txt", display;
  display = "Existing tags:\n";
  existingTags = loadStrings(fname);
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

String getCurFileName() {
  String[] s = split(filenames[cur], '.');
  return s[0];
}

public void input(String theText) {
  tagList.add(theText);
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
