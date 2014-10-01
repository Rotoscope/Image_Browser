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

PImage[] img;
String[] filenames;
int cur, left, mode, vel, isTransition;
int j;    //keeps track of the transition pixel shifts

void setup() {
  size(800, 600);
  background(45, 160, 220);
  
  /* initialize the starting mode and location of the pointers to the images */
  mode = 0;
  cur = 0;
  left = 0;
  vel = 5;
  j = 0;
  isTransition = 0;
  
  String path = sketchPath;
  filenames = listFileNames(path + "\\data");
  
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
}

void draw() {
  if(img != null) drawImage();
}

void drawImage() {
  background(45, 160, 220);
  if(isTransition == 0) {
    if(mode == 0)
      drawThumbs(left, 0);
    else if(mode == 1)
      singleImage(cur, 0);
  } else {
    if(isTransition < 0) {    //transition to the left
      if(mode == 1) {
        singleImage((cur + 1) % img.length, j);
        singleImage(cur, j - 800);
      } else if(mode == 0) {
        drawThumbs((left + 5) % img.length, j);
        drawThumbs(left, j - 800);
      }
      j += vel;
    } else if(isTransition > 0) {    //transition to the right
      if(mode == 1) {
        singleImage((cur + img.length - 1) % img.length, j);
        singleImage(cur, j + 800);
      } else if(mode == 0) {
        drawThumbs((left + img.length - 5) % img.length, j);
        drawThumbs(left, j + 800);
      }
      j -= vel;
    }
    if(j == 800 || j == -800) {
      j = 0;
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
  if(mouseY >= 250 && mouseY <= 350) {
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
  }
}

void keyPressed() {
  if(isTransition == 0) {  //keys only work if it is not in a transition phase
    if(key == CODED) {
      if(keyCode == UP && mode == 0) mode = 1;
      else if(keyCode == DOWN && mode == 1) {
        if(img.length > 5) left = (cur + img.length - 2) % img.length;
        mode = 0;
      } else if(keyCode == LEFT) {
        if(img.length > 5 && cur == left) {  //hit border so shift
          left = (left + img.length - 5) % img.length;
          isTransition = -1;
        }
        if(mode == 1) isTransition = -1;  //always shift when moved in single image
        cur = (cur + img.length - 1) % img.length;
      } else if(keyCode == RIGHT) {
        if(img.length > 5 && cur == (left + 4) % img.length) {  //hit border so shift
          left = (left + 5) % img.length;
          isTransition = 1;
        }
        if(mode == 1) isTransition = 1;  //always shift when moved in single image
        cur = (cur + 1) % img.length; 
      }
    }
    if((key == '>' || key == '.') && mode == 0) {
      isTransition = 1;
      cur = (cur + 5) % img.length;
      left = (left + 5) % img.length;
    }
    if((key == '<' || key == ',') && mode == 0) {
      isTransition = -1;
      cur = (cur + img.length - 5) % img.length;
      left = (left + img.length - 5) % img.length;
    }
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
