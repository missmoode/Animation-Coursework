/*
The layer class, extended in the main code for each layer.
Created as a helper function for better syntactic splittingg of layers in the code

*/

abstract class Layer {
  int[] mask; // The masking pixel array - defined in constructor
  PGraphics pg; // The image to draw on top of the mask
  
  public Layer(String maskPath) {
    PImage maskImage = loadImage(maskPath);
    maskImage.resize(500, 500);
    maskImage.loadPixels();
    this.mask = new int[maskImage.pixels.length];
    for (int cursor = 0; cursor < maskImage.pixels.length; cursor++) {
      if (alpha(maskImage.pixels[cursor]) > 0) { // Adapt the mask to a boolean state of opaque or transparent
        mask[cursor] = 255;
      } else {
        mask[cursor] = 0;
      }
    }
    this.pg = createGraphics(500, 500);
    
    setup();
  }
  
  abstract void setup(); // This will be written by the implementation
  
  void display() {
    pg.beginDraw();
    draw(pg);
    pg.endDraw();
    pg.mask(mask);
    image(pg, 0, 0, 500, 500);
  }
  
  abstract void draw(PGraphics graphics);  // This will be written by the implementation
  
}