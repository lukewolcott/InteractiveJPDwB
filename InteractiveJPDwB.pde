// Interactive demo of the persistence pipeline in 2D,
// building on javaplexDemo.pde from https://github.com/appliedtopology/javaplex.

// TODO:
// X -- clean up code into modular functions
// -- figure out how to clean interval data without saving and loading
//    by changing !full_lines[i].equals("") to !full_lines[i].equals(full_lines[2]) ??
// X -- load 1-4 at the beginning
// -- option to save 5-9 point clouds, using tyuio or Shift-5 etc
// X -- figure out how to remove points, with Shift-Click
// -- put in more instructions
// -- progress bar to match L/R parameter

import edu.stanford.math.plex4.api.*;
import edu.stanford.math.plex4.examples.*;
import edu.stanford.math.plex4.streams.impl.VietorisRipsStream;
import edu.stanford.math.plex4.homology.chain_basis.Simplex;
import edu.stanford.math.plex4.homology.filtration.FiltrationConverter;
import edu.stanford.math.plex4.homology.interfaces.AbstractPersistenceAlgorithm;
import edu.stanford.math.plex4.homology.barcodes.*;
import java.util.Map.Entry;
import java.util.List;

double[][] pts;
double[][] pts1, pts2, pts3, pts4;

float offsetX,offsetY,sizeX,sizeY;
int dragX,dragY,oldmouseX,oldmouseY;
double eps = 0.01;
double f = eps;
double maxeps = 0.3;
Table table;
VietorisRipsStream<double[]> vrs;
FiltrationConverter fc;
AbstractPersistenceAlgorithm<Simplex> algo;
BarcodeCollection<Double> ints=null;
float[][] intervals;
int num_pts = 0;
PFont ft;


void settings() {
  fullScreen();
}

void setup() {
  ft = createFont("Courier", 16, true);
  textFont(ft, 14);
  float xs = width;
  float ys = height;
  background(255);
  line(xs/2, 0, xs/2, 0.8*ys);
  line(0, 0.8*ys, xs, 0.8*ys);
  fill(0);
  draw_instructions(0, 0.8*ys, xs, ys);
  init_box(xs/2, 0, xs, 0.8*ys);
  fill(0);
  resetPoints();
  setupVRS();    
  pts1 = load_pts(1);
  pts2 = load_pts(2);
  pts3 = load_pts(3);
  pts4 = load_pts(4);  
}

void draw() {
//  background(255);
  fill(255);
  rect(0, 0, width/2, 0.8*height);
  stroke(0);
  fill(0);
  
    for(Simplex s : vrs) {
    double fv = fc.getFiltrationValue(vrs.getFiltrationIndex(s));
    if(fv > f)
      continue;

    int[] ix;
    ix = s.getVertices();

    switch(s.getDimension()) {
      case 0:
        fill(0);
        ellipse((float)pts[ix[0]][0],(float)pts[ix[0]][1],sizeX,sizeY);
        break;
      case 1:
        fill(0);
        line((float)pts[ix[0]][0],(float)pts[ix[0]][1],
            (float)pts[ix[1]][0],(float)pts[ix[1]][1]);
        break;
      case 2:
        fill(0,0,255,20);
        triangle((float)pts[ix[0]][0],(float)pts[ix[0]][1],
            (float)pts[ix[1]][0],(float)pts[ix[1]][1],
            (float)pts[ix[2]][0],(float)pts[ix[2]][1]);
        break;
      default:
        continue;
    }
  }
}

//*****************************************
// Compute a new VietorisRipsStream
//*****************************************

void setupVRS() {
  vrs = Plex4.createVietorisRipsStream(pts,2,maxeps,1000);
  fc = vrs.getConverter();
  ints=null;
}

//*****************************************
// Reset the points buffer
//*****************************************

void resetPoints() {
      pts=new double[0][2];
      dragX=0;
      dragY=0;
      offsetX=0;
      offsetY=0;
      sizeX=5;
      sizeY=5;
      f = 10;
      eps = 10;
      maxeps = 300;
}

//*****************************************
// Display instructions at bottom
//*****************************************

void draw_instructions(float xa, float ya, float xb, float yb) {
  int h = 14;
  text("INSTRUCTIONS", xa+30, h+ya);
  text("1-4    -- loads pre-stored data sets", xa+10, 2*h + ya);
  text("click  -- adds a point (and SHIFT-click removes a point)", xa +10, 3*h + ya); 
  text("B      -- run homology computation and plot barcode (although this should happen automatically)", xa + 10, 4*h+ya);
  text("LEFT   -- step Vietoris-Rips complex back", xa+10, 5*h+ya);
  text("RIGHT  -- step Vietoris-Rips complex forward", xa+10, 6*h+ya);
  text("C      -- clear points", xa + 10, 7*h+ya);
  text("Q      -- quit", xa+10, 8*h+ya);
}

//*****************************************
// Initialize barcode box
//*****************************************

void init_box(float xa, float ya, float xb, float yb) {
  float cx = (xa + xb)/2;
  float cy = (ya + yb)/2;
  fill(255);
  stroke(0,0,204);
  strokeWeight(1.5);
  rect(cx - 250, cy - 250, 500, 500);
  stroke(0);
  strokeWeight(1);
}

//*****************************************
// On mousepress, if within data box then add a point. 
//*****************************************

void mousePressed() {
  if (keyPressed && keyCode == SHIFT){ // have shift-click
    for (int i = 0; i < pts.length; i++){
      if (sq((float) pts[i][0]-mouseX)+sq((float) pts[i][1]-mouseY) < 25){  
        // somehow take (pts[i][0], pts[i][1]) out of pts...
        pts = remove_row(i);
        //println("should remove point: " + pts[i][0] + ", " + pts[i][1]);
        //text("REMOVE THE POINT", 50, 50+12*i);
        setupVRS();
        draw_barcode();
        break;
      }
    }
  }
  else{ // don't have shift-click, so add point
    if ((mouseX < width/2) && (mouseY < 0.8*height)) {
      double[] pt = new double[2];

      translate(dragX,dragY);
      translate(offsetX,offsetY);

      pt[0] = mouseX;
      pt[1] = mouseY;
      
      println(pt[0]+","+pt[1]);
      pts = (double[][]) append(pts,pt);
      setupVRS();
      draw_barcode();
    }
  }
}

//*****************************************
// On keypress:
//
// Q      -- quit
// C      -- clear points
// B      -- run homology computation and plot barcode
// LEFT   -- step Vietoris-Rips complex back
// RIGHT  -- step Vietoris-Rips complex forward
//*****************************************

void keyPressed() {
  float x_size = width/2;
  float y_size = 0.8*height;
  switch(key) {
    case 'q':
    case 'Q':
      exit();
      break;
      
    case 'c':
    case 'C':
      resetPoints();
      setupVRS();
      draw_barcode();
      break;
      
    case 'b':
    case 'B':
      draw_barcode();
      break;
    
    case '1':                              
      pts = pts1;
      setupVRS();
      draw_barcode();
      break;    
  
    case '2':                              
      pts = pts2;
      setupVRS();
      draw_barcode();
      break;
     
    case '3':                              
      pts = pts3;
      setupVRS();
      draw_barcode();
      break;
     
    case '4':                             
      pts = pts4;
      setupVRS();
      draw_barcode();
      break;
      
    case CODED:
      switch(keyCode) {
        case RIGHT:
          f += eps;
          println(f+": "+eps);
          break;
        case LEFT:
          f -= eps;
          println(f+": "+eps);
          if(f<0)
            f=0;
          break;
    }
     
    
    
  }
}

//*****************************************
// Load pre-saved data into tables so it is ready to be read with 1-4.
//*****************************************

double[][] load_pts(int n) {
  double[][] ptsn;
  Table tablen;
  if (n==1)
    tablen = loadTable("seed1_data.csv", "header");
  else if (n==2)
    tablen = loadTable("seed2_cross.csv", "header");
  else if (n==3)
    tablen = loadTable("seed3_cross_hole_005.csv", "header");
  else 
    tablen = loadTable("seed4_circle.csv", "header");              
  ptsn = new double[tablen.getRowCount()][2];
  for (TableRow row : tablen.rows()){
    ptsn[row.getInt("point_id")][0] = row.getDouble("X_value")*width/2*0.9+width/2*0.05;
    ptsn[row.getInt("point_id")][1] = row.getDouble("Y_value")*0.8*height*0.9+0.8*height*0.05;
    }
  return ptsn;
}

//*****************************************
// Convert the output of a Javaplex persistence interval calculation into a tidy array.
//*****************************************

float[][] ints_to_intervals(String s){    
  String[] sss = splitTokens(s, " [,)");  
  String save_path = sketchFile("") + "/data/intervals_p3.txt";
  saveStrings(save_path, sss);
  String[] full_lines = loadStrings("intervals_p3.txt");
  //String[] full_lines = sss;

  // print how many full lines there are, and then print each full line
  println("there are " + full_lines.length + " full lines");
  for (int i=0; i<full_lines.length; i++){
    println(full_lines[i]);
  }
    
  // Remove the empty lines.
  String lines[] = {};
  for (int i=0; i<full_lines.length; i++){
    if (!full_lines[i].equals("")){
      lines = append(lines, full_lines[i]);
    }
  }

  // print how many lines, and then print each line
  println("there are " + lines.length + " lines");
  for (int i=0; i<lines.length; i++){
    println(lines[i]);
  }

  // Count how many different dimensions and points.
  int num_dims = 0;
  for (int i=0; i<lines.length; i++){
    if (lines[i].equals("Dimension:")){
      num_dims = num_dims + 1;
    }
  }      

  // print how many dimensions there are, and how many intervals there are
  println("there are " + num_dims + " different dimensions");
  num_pts = lines.length/2 - num_dims;
  println("there are " + num_pts + " different intervals");            

  // Build array of dimension, start, end.
  intervals = new float[num_pts][3];
  int dim = 0;
  int pt_number=-1;
  for (int k = 0; k<lines.length/2; k++){
    if (lines[2*k].equals("Dimension:")){
      dim = int(lines[2*k+1]);
      println("dim:" + dim);
    }
    else{
      pt_number = pt_number + 1;
      println(pt_number);
      intervals[pt_number][0] = dim;
      intervals[pt_number][1] = float(lines[2*k]);
      intervals[pt_number][2] = float(lines[2*k+1]);
    }  
  }  

  // print array of intervals
  for( int j=0; j<num_pts; j++){
    println(intervals[j][0], intervals[j][1], intervals[j][2]);
  } 
  
  return intervals;
}


//*****************************************
// Draw the barcode corresponding to a tidy array of intervals.
//*****************************************

void array_to_barcode(float[][] intervals){
    int nrow = intervals.length;
       
  // Look through table and figure out where the dimension changes.  
  int[] spots = {0};
  for (int i=1; i<nrow; i = i + 1){
    if (intervals[i][0] > intervals[i-1][0] ){
      spots = (int[]) append(spots,i);
    }
  }
    
  // Figure out what those dimensions actually are.  
  int[] dims = {int(intervals[0][0])};
  for (int i=1; i<spots.length; i=i+1){
    dims = (int[]) append(dims, int(intervals[spots[i]][0]));
  }
  spots = (int[]) append(spots,nrow);
  
  // Figure out horizontal scale.
  float max = 0;
  float real_max;
  for (int i=0; i<nrow; i=i+1){
    if (intervals[i][2] > max){
      max = intervals[i][2];
    }
  }
  real_max = max;
  println("Max value is " + max + ".");
  println("Infinite lines go all the way to end.");
  max = max*(1.1);        // Rescale so max isn't cut off. 

  // Convert infinity to max length.
  for (int i=0; i<nrow; i=i+1){
    if(Float.isNaN(intervals[i][2])){
      intervals[i][2] = max;
    }
  }     
  
  // Start drawing lines.
  float a = 0.75*width - 250;
  float b = 0.4*height - 250;
  float spaces = nrow - dims.length + 2 + 2 +4*(dims.length-1);
  float incr = 500/spaces;
  float y=b;      
  textSize(10);
  fill(0);
  for (int j=0; j<dims.length; j=j+1){
    y = y + 2*incr;
    text("dim " + dims[j], a-40, y);
    for (int k=spots[j]; k<spots[j+1]; k=k+1){    
      float start = intervals[k][1];
      float finish = intervals[k][2];
      line(a + 500*(start/max), y, a + 500*(finish/max), y);
      y = y + incr;
    }
    if (j < (dims.length-1)){
      y = y + 1*incr;
      stroke(0,0,204);
      strokeWeight(1.5);
      line(a, y, a+500, y);        // Draws a full line to separate dimensions
      stroke(0);
      strokeWeight(1);
    }
  }
  text(int(max), a+490, b+515);     
}
  
void draw_barcode(){
      // compute intervals
      algo = Plex4.getDefaultSimplicialAlgorithm(2);
      ints = algo.computeIntervals(vrs);
      //println(ints);
      String s = ints.toString();
      
      // convert intervals into tidy array
      intervals = ints_to_intervals(s);
      
      //initialize barcode region   
      fill(255);
      rect(width/2, 0, width, 0.8*height);
      init_box(width/2, 0, width, 0.8*height);      
      
      // quit if there are no points in the array
      if (intervals.length == 0) {
        return;
      }
      
      // draw barcode from tidy array
      array_to_barcode(intervals);
}
  
//*****************************************
// Remove a row from pts.
//*****************************************
  
double[][] remove_row(int r){
  double[][] temp = new double[0][2];
  for (int i=0; i<pts.length; i++){
    if (i != r)
      temp = (double[][]) append(temp, pts[i]);
  }
  return temp;
}
  
  
  
  
  
  
  
  
  
  