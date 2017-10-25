import controlP5.*;

ControlP5 cp5;
float dA0, dB0, feed0, kill0, noiseamt, noisemv, noisesize, flow, balpha;
float dA1, dB1, feed1, kill1;
color color1, color2, color3;

PShader reaction, blur, colorize;
PGraphics pg0, pg1, pg2, pgblur, pgcolor;
int count = 0;
boolean reset;
int iterations = 1;
boolean showUI = false;
boolean colorizeit = false;
boolean record = false;
boolean paused = false;
boolean brush = false;
boolean blurEnabled = false;
int mode = 0;

void addParamSliders(int layerId) {
  float offset = layerId * 260;
  cp5.addSlider("dA"+layerId).setPosition(30+offset,30)
                       .setSize(200,10)
                       .setRange(0,1.)
                       .setValue(.9);
  cp5.addSlider("dB"+layerId).setPosition(30+offset,50)
                       .setSize(200,10)
                       .setRange(0,1.)
                       .setValue(.4);
  cp5.addSlider("feed"+layerId).setPosition(30+offset,70)
                       .setSize(200,10)
                       .setRange(0,1.)
                       .setValue(.0434);
  cp5.addSlider("kill"+layerId).setPosition(30+offset,90)
                       .setSize(200,10)
                       .setRange(0,1.)
                       .setValue(.055);
}

void setup() {
  size(1000, 1000, P2D);
  cp5 = new ControlP5(this);
  addParamSliders(0);
  addParamSliders(1);
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
  cp5.addSlider("balpha").setPosition(30,210)
                      .setSize(200,10)
                      .setRange(0,1.)
                      .setValue(0);
  cp5.addColorWheel("color1" , width-130, 30 , 100).setRGB(color(.7*255, .1*255, .95*255));
  cp5.addColorWheel("color2" , width-130, 150 , 100).setRGB(color(0, .4*255, .6*255));
  cp5.addColorWheel("color3" , width-130, 270 , 100).setRGB(color(0, .05*255, .2*255));

  pg0 = createGraphics(width*2, height*2, P2D);
  pg0.noSmooth();
  pg1 = createGraphics(width/4, height/4, P2D);
  pg1.noSmooth();
  pg2 = createGraphics(width/16, height/16, P2D);
  pg2.noSmooth();
  pgblur = createGraphics(pg0.width, pg0.height, P2D);
  pgblur.noSmooth();
  pgcolor = createGraphics(width, height, P2D);
  reaction = loadShader("reaction.frag");
  colorize = loadShader("colorize.frag");
  blur = loadShader("blur.frag");
  colorize.set("resolution", float(pg0.width), float(pg0.height));
}

PVector colorVec(color c) {
  return new PVector(red(c)/255., green(c)/255., blue(c)/255.);
}

void setReactionParameters(int layerId) {
  if(layerId == 0) {
    reaction.set("dA", dA0);
    reaction.set("dB", dB0);
    reaction.set("kill", feed0);
    reaction.set("feed", kill0);
    reaction.set("resolution", float(pg0.width), float(pg0.height));
  }
  else if(layerId == 1) {
    reaction.set("dA", dA1);
    reaction.set("dB", dB1);
    reaction.set("kill", feed1);
    reaction.set("feed", kill1);
    reaction.set("resolution", float(pg1.width), float(pg1.height));
  }
  else if(layerId == 2) {
    reaction.set("dA", dA1);
    reaction.set("dB", dB1);
    reaction.set("kill", feed1);
    reaction.set("feed", kill1);
    reaction.set("resolution", float(pg2.width), float(pg2.height));
  }
}

void draw() {
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
      // low res.
      setReactionParameters(2);
      pg2.beginDraw();
      pg2.shader(reaction);
      pg2.background(0);
      pg2.rect(0, 0, pg2.width, pg2.height);
      pg2.endDraw();

      // apply blur
      pgblur.beginDraw();
      pgblur.shader(blur);
      pgblur.image(pg2, 0, 0, pgblur.width, pgblur.height);
      pgblur.endDraw();

      // mid res
      setReactionParameters(1);
      pg1.beginDraw();
      pg1.tint(255, balpha*255);
      pg1.image(pgblur, 0, 0, pg1.width, pg1.height);
      pg1.endDraw();
      pg1.beginDraw();
      pg1.shader(reaction);
      pg1.rect(0, 0, pg1.width, pg1.height);
      pg1.endDraw();

      // apply blur
      pgblur.beginDraw();
      pgblur.shader(blur);
      pgblur.image(pg1, 0, 0, pgblur.width, pgblur.height);
      pgblur.endDraw();

      // high res
      setReactionParameters(0);
      pg0.beginDraw();
      pg0.resetShader();
      pg0.tint(255, balpha*255);
      pg0.image(pgblur, 0, 0, pg0.width, pg0.height);
      pg0.endDraw();
      pg0.beginDraw();
      pg0.background(0);
      pg0.shader(reaction);
      pg0.rect(0, 0, pg0.width, pg0.height);
      pg0.endDraw();
    }

    PGraphics tmp = pg0;
    if(mode == 1) tmp = pg1;
    else if(mode == 2) tmp = pg2;

    if(colorizeit) {
      pgcolor.beginDraw();
      pgcolor.background(0);
      pgcolor.shader(colorize);
      pgcolor.image(tmp, 0, 0, width, height);
      pgcolor.resetShader();
      pgcolor.endDraw();
      image(pgcolor, 0, 0, width, height);
      if(record) pgcolor.save("frames/frame"+frameCount+".tga");
    }
    else {
      image(tmp, 0, 0, width, height);
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
}

void seedWithTex(String texpath) {
  PImage tex = loadImage(texpath);
  pg0.beginDraw();
  pg0.resetShader();
  pg0.image(tex, 0, 0, pg0.width, pg0.height);
  pg0.endDraw();
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
  if(key == 'n') blurEnabled = !blurEnabled;
  if(key == '0') mode = 0;
  if(key == '1') mode = 1;
  if(key == '2') mode = 2;
}
