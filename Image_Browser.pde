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

PImage img;

void setup() {
  size(400, 300);
  fill(45, 160, 220);    //border color
  rect(0, 0, 400, 300);  //fill background with color
  
  String path = sketchPath;
  String[] filenames = listFileNames(path);
  println(filenames);
  
  img = loadImage(filenames[0]);
}

void draw() {
  image(img,0,0);
}

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

// This function returns all the files in a directory as an array of File objects
// This is useful if you want more info about the file
File[] listFiles(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    File[] files = file.listFiles();
    return files;
  } else {
    // If it's not a directory
    return null;
  }
}
