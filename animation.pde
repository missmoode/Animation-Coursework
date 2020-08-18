/*
   This processing sketch is written in two files - the
   main file containing the main code defining the animation
   and a utility class called Layer in its own file which
   makes it easier to build separate graphics and mask them
   inside of the components of the keele logo. It also
   contains a folder of images which are used as the masking
   templates.
   
   It consists of four main animations, which are marked and
   annotated with comments below:
    - The sun beams
    - The windmills
    - The blades of grass
    - The earth day countdown
    
   It also has a basic interaction - a parallax effect on the
   blades of grass which responds to the x position of the
   mouse on the window.
*/

import java.util.Date;
import java.util.GregorianCalendar;
import java.util.Calendar;

/*
  Set up some constantas to use later and keep them up here
  for efficiency and ease of readability's sake
*/

static long MILLIS_PER_MINUTE = 1000 * 60;
static long MILLIS_PER_HOUR = MILLIS_PER_MINUTE * 60;
static long MILLIS_PER_DAY = MILLIS_PER_HOUR * 24; // Used for the calculation of time between dates;


PImage frame, bookandscythe;
Layer section1, section2, section3;
Date earthDay = new GregorianCalendar(year(), Calendar.APRIL, 22).getTime();


void setup() {
  size(500,600);
  
  if (earthDay.getTime() - System.currentTimeMillis() < 0) { // Earth day has already passed, use next year
    earthDay = new GregorianCalendar(year()+1, Calendar.APRIL, 22).getTime();
  }

  frame = loadImage("masks/frame.png");
  
  /*
    Section 1
    Sun beams:
    
    This effect was achieved by creating several triangles at
    rotations. This effect was achieved by creating triangles at
    at 36 degree intervals with a width of 20 degrees on the end.
    The same effect could also have been achieved with rotate(),
    but for demonstration purposes trigonometry was used.
    
    In order to avoid re-rendering the image every time the
    sunbeam image is created only once on the first load, and
    this image is inserted with rotation on every draw.
  */
  section1 = new Layer("masks/section1.png") {
    PGraphics rays;
    
    public void setup() {
      rays = createGraphics(500, 500); // Create a new graphic so we dont have to redraw this every time
      rays.beginDraw();
      rays.translate(250, 250);
      rays.noStroke();
      int width = 20;
      for (int angle = 0; angle < 360; angle = angle + 36) {
        rays.fill(0, 0, 0, 30);
        rays.triangle(0, 0, 
                sin(radians(angle-width/2))*250, cos(radians(angle-width/2))*250,
                sin(radians(angle+width/2))*250, cos(radians(angle+width/2))*250
        );
      }
      rays.endDraw();
    }
    
    public void draw(PGraphics g) {
      g.background(235, 204, 46);
      g.translate(250, 250);
      g.rotate(-radians((360*(millis()/25000f))%360)); //Rotate counterclockwise at 25 seconds per revolution
      g.image(rays, -250, -250);
    }
  };
  
  /*
    Section 2
    Wind turbines:
    
    This effect was achieved by drawing the towers and iterating three
    times - once for each blade. The angle of rotation for each blade
    is added to a distance in degrees based on the time elapsed in the
    program which creates rotation.
    It may have been more efficient to draw the entire blade assembly once
    as a graphic and then just placed it with a rotation, but this was
    not done, again for demonstration purposes.
  */
  section2 = new Layer("masks/section2.png") {
    public void setup() {
    }
    
    public void draw(PGraphics g) {
      g.background(217, 56, 32);
      
      PGraphics turbine = createGraphics(400, 800);
      turbine.beginDraw();
      turbine.blendMode(REPLACE); // Ensure that the shapes dont show overlap for stylistic reasons
      turbine.fill(0, 0, 0, 100);
      turbine.noStroke();
      turbine.rect(185, 200, 30, 600);
      turbine.ellipse(200, 200, 60, 60);
      turbine.pushMatrix();
        turbine.translate(200, 200);
        turbine.stroke(0, 0, 0, 100);
        turbine.strokeWeight(20);
        turbine.strokeCap(ROUND);
        for (int i = 0; i < 360; i = i + 360/3) { // Could also just achieve this using a 1-3 loop but this way allows us to also use the i value as the angle
          float angle = -radians(i+(360*(millis()/8000f))%360); //Rotate clockwise at 8 seconds per revolution 
          turbine.line(0, 0, sin(angle)*100, cos(angle)*100);
        }
      turbine.popMatrix();
      turbine.endDraw();
      
      g.image(turbine, 260, 110, 200, 400);
      g.image(turbine, 235, 150, 100, 200);
      g.image(turbine, 100, 180, 150, 300);
    }
  };
  
  /*
    Section 3
    Grass:
    
    This effect is based on bezier grass, but all pointing in a 
    single direction to better emulate real grass in wind.
    It's distributed based on perlin noise, which gives a decent 
    approximation of real patches of grass. This method also 
    determines grass height.
    
    The grass flows in waves, using sin waves with an offset based 
    on the position of the grass. This allows for propewr smoothing
    and springy movements which works well for grass.
    
    In an attempt to add a bit of interactivity to the animation,
    the grass also has a 3d effect. The grass moves in response to
    the mouse, with the amount determined by y position. This
    creates a 3d parallax effect.
  */
  section3 = new Layer("masks/section3.png") {
    public void setup() {
    }
    
    public void draw(PGraphics g) {
      float scroll = 1-mouseX/500f*2; // calculate a scroll location from -1 to 1 based on mouse x percentage across entire width
      
      g.background(46, 172, 103);
      PGraphics overlay = createGraphics(500, 500); // Create a new graphic so we can make our grass transparent and use the REPLACE blend mode
      overlay.beginDraw();  
      overlay.blendMode(REPLACE);
      overlay.noFill();
      overlay.stroke(0, 0, 0, 100);
      for (int x = 80; x < 430; x = x + 6) {
          for (int y = 0; y < 120; y = y + 6) {
            if (noise(x, y) < .65) continue;
            overlay.pushMatrix();
              float wind = (float) 1+sin((x*10+millis())/(1000f/2)); // Create waves of wind that take 2 seconds to complete
              overlay.strokeWeight(5-noise(x, y)*2); // Adjust width of blades to give sense of depth
              overlay.translate(x+y*(scroll-.5), 440+y-60); // Add parallax based on scroll and add a plus or minus 60 pixels variance to vary height
              overlay.bezier(0, 0, 
                            0, -15, 
                            -5*wind, -30, 
                            -5-5*wind, -noise(x, y)*30-20);
            overlay.popMatrix();
          }
      }
      overlay.endDraw();
      g.image(overlay, 0, 0);
    }
  };
  bookandscythe = loadImage("masks/bookandscythe.png");
}

void draw() {
  background(255);
  image(frame, 0, 0, 500, 500);
  section1.display();
  section2.display();
  section3.display();
  image(bookandscythe, 0, 0, 500, 500);
  
  long timeUntil = earthDay.getTime() - System.currentTimeMillis();
  
  /*
    A simple text-based countdown timer. Uses string formatting to correctly show fixed-digit counters for each value.
  */
  pushMatrix();
    textAlign(CENTER, CENTER);
    translate(250, 510);
    noStroke();
    fill(0);
    rect(-200, 3, 400, 1);
    fill(255);
    rect(-100, 2, 200, 2);
    fill(0);
    textSize(20);
    text("Earth Day Begins in", 0, 0);
    textSize(22);
    // Section 4
    String time = String.format("%d day(s) %02d hour(s)\n%02d minute(s) %02d second(s)",
      timeUntil / MILLIS_PER_DAY, // Days, rounded by taking advantage of integer division
      timeUntil % MILLIS_PER_DAY / MILLIS_PER_HOUR, // Hours
      timeUntil % MILLIS_PER_HOUR / MILLIS_PER_MINUTE, // Minutes
      timeUntil % MILLIS_PER_MINUTE / 1000 // Seconds
    );
    text(time, 0, 50);
  popMatrix();
}