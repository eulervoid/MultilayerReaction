import controlP5.*;

ControlP5 cp5;
float dA, dB, feed, kill, noiseamt, noisemv, noisesize, flow;
color color1, color2, color3;

PShader reaction, blur, colorize;
PGraphics pglow, pg, pgcolor;
int count = 0;
boolean reset;
int iterations = 1;
boolean showUI = false;
boolean colorizeit = false;
boolean record = false;
boolean paused = false;
boolean brush = false;

void setup() {
  size(1000, 1000, P2D);
  cp5 = new ControlP5(this);
  cp5.addSlider("dA").setPosition(30,30)
                       .setSize(200,10)
                       .setRange(0,1.)
                       .setValue(.9);
  cp5.addSlider("dB").setPosition(30,50)
                       .setSize(200,10)
                       .setRange(0,1.)
                       .setValue(.4);
  cp5.addSlider("feed").setPosition(30,70)
                       .setSize(200,10)
                       .setRange(0,1.)
                       .setValue(.0434);
  cp5.addSlider("kill").setPosition(30,90)
                       .setSize(200,10)
                       .setRange(0,1.)
                       .setValue(.055);
  cp5.addSlider("noiseamt").setPosition(30,130)
                      .setSize(200,10)
                      .setRange(0,.1)
                      .setValue(.05);
  cp5.addSlider("noisemv").setPosition(30,150)
                       .setSize(200,10)
                       .setRange(0,1)
                       .setValue(.1);
 cp5.addSlider("noisesize").setPosition(30,170)
                      .setSize(200,10)
                      .setRange(5,0.5)
                      .setValue(.1);
  cp5.addSlider("flow").setPosition(30,190)
                      .setSize(200,10)
                      .setRange(0,2.)
                      .setValue(1);
  cp5.addColorWheel("color1" , width-130, 30 , 100).setRGB(color(.7*255, .1*255, .95*255));
  cp5.addColorWheel("color2" , width-130, 150 , 100).setRGB(color(0, .4*255, .6*255));
  cp5.addColorWheel("color3" , width-130, 270 , 100).setRGB(color(0, .05*255, .2*255));

  pg = createGraphics(width, height, P2D);
  pg.noSmooth();
  pglow = createGraphics(width/8, height/8, P2D);
  pglow.noSmooth();
  pgcolor = createGraphics(width, height, P2D);
  reaction = loadShader("reaction.frag");
  colorize = loadShader("colorize.frag");
  blur = loadShader("blur.frag");
  colorize.set("resolution", float(pg.width), float(pg.height));
}

PVector colorVec(color c) {
  return new PVector(red(c)/255., green(c)/255., blue(c)/255.);
}

void draw() {
  reaction.set("dA", dA);
  reaction.set("dB", dB);
  reaction.set("kill", feed);
  reaction.set("feed", kill);
  reaction.set("noiseamt", noiseamt);
  reaction.set("noisemv", noisemv);
  reaction.set("noisesize", noisesize);
  reaction.set("flow", flow);
  reaction.set("time", (float)frameCount/30.);
  reaction.set("brush", brush);
  colorize.set("color1", colorVec(color1));
  colorize.set("color2", colorVec(color2));
  colorize.set("color3", colorVec(color3));

  for(int i=0; i<iterations; i++) {
    //reaction.set("time", millis()/1000.0);
    float x = map(mouseX, 0, width, 0, 1);
    float y = map(mouseY, 0, height, 1, 0);
    reaction.set("mouse", x, y);

    if(!paused) {
      reaction.set("resolution", float(pglow.width), float(pglow.height));
      pglow.beginDraw();
      pglow.shader(reaction);
      pglow.background(0);
      pglow.rect(0, 0, pglow.width, pglow.height);
      pglow.endDraw();
      reaction.set("resolution", float(pg.width), float(pg.height));
      pg.beginDraw();
      pg.shader(blur);
      pg.image(pglow, 0, 0, pg.width, pg.height);
      pg.resetShader();
      pg.endDraw();
      pg.beginDraw();
      pg.background(0);
      pg.shader(reaction);
      pg.rect(0, 0, pg.width, pg.height);
      pg.endDraw();
    }

    if(colorizeit) {
      pgcolor.beginDraw();
      pgcolor.background(0);
      pgcolor.shader(colorize);
      pgcolor.image(pg, 0, 0, width, height);
      pgcolor.resetShader();
      pgcolor.endDraw();
      image(pgcolor, 0, 0, width, height);
      if(record) pgcolor.save("frames/frame"+frameCount+".tga");
    }
    else {
      image(pg, 0, 0, width, height);
    }

    // reload shader every 100 frames
    //if(frameCount % 100 == 0) { reloadShader(); count = 0; }
    if(reset) {
      reaction.set("clear", 1);
      reset = false;
    }
    //if(record) saveFrame("frames/frame####.tga");
  }
}

void reloadShaders() {
  reaction = loadShader("reaction.frag");
  reaction.set("resolution", float(pg.width), float(pg.height));
}

void seedWithTex(String texpath) {
  PImage tex = loadImage(texpath);
  pg.beginDraw();
  pg.resetShader();
  pg.image(tex, 0, 0, pg.width, pg.height);
  pg.endDraw();
}

void keyPressed() {
  if(key == ' ') record = !record;
  if(key == 'y') reloadShaders();
  if(key == 'x') {
    showUI = !showUI;
    cp5.setVisible(showUI);
  }
  if(key == 'c') colorizeit = !colorizeit;
  if(key == '.') seedWithTex("data/tex.png");
  if(key == 'p') paused = !paused;
  if(key == 'b') brush = !brush;
}
