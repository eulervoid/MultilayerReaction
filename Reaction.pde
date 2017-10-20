// GLSL version of Conway's game of life, ported from GLSL sandbox:
// http://glsl.heroku.com/e#207.3
// Exemplifies the use of the ppixels uniform in the shader, that gives
// access to the pixels of the previous frame.
PShader conway;
PGraphics pg;
int count = 0;

void setup() {
  size(800, 800, P2D);
  pg = createGraphics(800, 800, P2D);
  pg.smooth();
  conway = loadShader("reaction.frag");
  conway.set("resolution", float(pg.width), float(pg.height));
}

void draw() {
  conway.set("time", millis()/1000.0);
  float x = map(mouseX, 0, width, 0, 1);
  float y = map(mouseY, 0, height, 1, 0);
  conway.set("mouse", x, y);
  image(pg, 0, 0, width, height);
  pg.beginDraw();
  pg.shader(conway);
  pg.rect(0, 0, pg.width, pg.height);
  pg.endDraw();
  // reload shader every 100 frames
  if(frameCount % 100 == 0) { reloadShader(); count = 0; }
}

void reloadShader() {
  conway = loadShader("reaction.frag");
  conway.set("resolution", float(pg.width), float(pg.height));
}

void keyPressed() {
  reset();
}

void reset() {
  pg.beginDraw();
  pg.background(255, 0, 0);
  pg.fill(0, 0, 200);
  pg.rect(100, 100, 100, 100);
  pg.endDraw();
}
