/******
  File: 
  By: Stanley Seeto
  Date: 
  
  Compile: Processing 2.2.1 run button
  Usage: Processing 2.2.1 run button
  System: used Windows 7
  
  Description: image browser; left & right scroll;
    up opens & down minimizes; > < skips to next set
    displays image in the data folder

*******/

PImage[] img;
String[] filenames;
int cur, left, mode;

void setup() {
  size(800, 600);
  frameRate(4);
  drawBG();
  
  /* initialize the starting mode and location of the pointers to the images */
  mode = 0;
  cur = 0;
  left = 0;
  
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

void drawBG() {
  fill(45, 160, 220);    //border color
  rect(0, 0, 800, 600);  //fill background with color
}

void drawImage() {
  if(mode == 0) {
    drawBG();
    drawThumbs();
  } else if(mode == 1) {
    drawBG();
    //displays rescale original resolution instead of stored scaled image
    img[cur] = loadImage(filenames[cur]);
    int i = resChk(img[cur]);
    if(i == -1 || i == 0) {
      img[cur].resize(0, 500);
      image(img[cur], (700 - img[cur].width) / 2 + 50, 50);
    } else if(i == 1) {
      img[cur].resize(700, 0);
      image(img[cur], 50, (500 - img[cur].height) / 2 + 50);
    }
  }
}

void drawThumbs() {
  int k;
  int xStart = 50;
  
  /* border for current image */
  fill(230, 165, 70);
  int loc = cur - left;
  if(loc < 0) loc = loc + img.length;
  rect(loc * 150 + 25, 225, 150, 150);
  
  int j = left;
  int max = 5;
  if(img.length < 5) max = img.length;
  for(int i = 0; i < max; i++) {
    k = resChk(img[j]);
    if(k == -1 || k == 0) {
      img[j].resize(0, 100);
      image(img[j], (100 - img[j].width) / 2 + xStart, 250);
    } else if(k == 1) {
      img[j].resize(100, 0);
      image(img[j], xStart, (100 - img[j].height) / 2 + 250);  
    }
    j = (j + 1) % img.length;
    xStart += 150;   
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
  if(key == CODED) {
    if(keyCode == UP && mode == 0) mode = 1;
    else if(keyCode == DOWN && mode == 1) {
      if(img.length > 5) left = (cur + img.length - 2) % img.length;
      mode = 0;
    } else if(keyCode == LEFT) {
      if(img.length > 5 && cur == left) left = (left + img.length - 5) % img.length;
      cur = (cur + img.length - 1) % img.length;
    } else if(keyCode == RIGHT) {
      if(img.length > 5 && cur == (left + 4) % img.length) left = (left + 5) % img.length;
      cur = (cur + 1) % img.length;
    }
  }
  if(key == '>' || key == '.') {
    cur = (cur + 5) % img.length;
    left = (left + 5) % img.length;
  }
  if(key == '<' || key == ',') {
    cur = (cur + img.length - 5) % img.length;
    left = (left + img.length - 5) % img.length;
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
