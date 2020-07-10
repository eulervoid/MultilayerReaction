import controlP5.*;

ControlP5 cp5;
color color1, color2, color3;

PShader blur, colorize;
PGraphics pgblur, pgcolor;
int count = 0;
boolean reset;
int iterations = 3;
boolean showUI = false;
boolean colorizeit = false;
boolean record = false;
boolean paused = false;
boolean brush = false;
boolean blurEnabled = false;
boolean zoom = false;
int mode = 0;

RDLayer l1, l2, l3;

void setup() {
  int w = 1080;
  int h = 1080;
  size(1080, 1080, P3D);
  frameRate(30);
  cp5 = new ControlP5(this);
  l1 = new RDLayer(1, w, h);
  l1.addSliders(cp5, 30, 30);
  
  l2 = new RDLayer(2, width/2, height/2);
  l2.addSliders(cp5, 280+30, 30);
  
  l3 = new RDLayer(3, width/4, height/4);
  l3.addSliders(cp5, 2*280+30, 30);

  cp5.addColorWheel("color1" , width-130, 30 , 100).setRGB(color(.7*255, .1*255, .95*255));
  cp5.addColorWheel("color2" , width-130, 150 , 100).setRGB(color(0, .4*255, .6*255));
  cp5.addColorWheel("color3" , width-130, 270 , 100).setRGB(color(0, .05*255, .2*255));

  pgblur = createGraphics(width, height, P2D);
  pgblur.noSmooth();
  pgcolor = createGraphics(l1.layer.width, l1.layer.height, P2D);

  colorize = loadShader("colorize.frag");
  blur = loadShader("blur.frag");
  colorize.set("resolution", float(width), float(height));
}

PVector colorVec(color c) {
  return new PVector(red(c)/255., green(c)/255., blue(c)/255.);
}

void applyBlur(PGraphics pg) {
  pgblur.beginDraw();
  pgblur.shader(blur);
  pgblur.image(pg, 0, 0, pgblur.width, pgblur.height);
  pgblur.endDraw();
}

void draw() {
  colorize.set("color1", colorVec(color1));
  colorize.set("color2", colorVec(color2));
  colorize.set("color3", colorVec(color3));
  
  for(int i=0; i<iterations; i++) {
    //reaction.set("time", millis()/1000.0);
    float x = map(mouseX, 0, width, 0, 1);
    float y = map(mouseY, 0, height, 1, 0);
    l1.reaction.set("mouse", x, y);
    l2.reaction.set("mouse", x, y);
    l3.reaction.set("mouse", x, y);
    l1.reaction.set("time", frameCount/30.);
    l2.reaction.set("time", frameCount/30.);
    l3.reaction.set("time", frameCount/30.);

    if(!paused) {
      
      // low res.
      l3.draw();
        
      applyBlur(l3.get());
      
      // mid res
      l2.add(pgblur);
      l2.draw();

      applyBlur(l2.get());
      
      if(mode < 2) {
        // high res
        l1.add(pgblur);
        l1.draw();
      }
    }

    PGraphics tmp = l1.get();
    if(mode == 2) tmp = l2.get();
    else if(mode == 3) tmp = l3.get();

    if(colorizeit) {
      pgcolor.beginDraw();
      pgcolor.background(0);
      pgcolor.shader(colorize);
      pgcolor.image(tmp, 0, 0, pgcolor.width, pgcolor.height);
      pgcolor.resetShader();
      pgcolor.endDraw();
      if(zoom)
        image(pgcolor, -(width*3.5), -(height*3.5), width*7, height*7);
      else
        image(pgcolor, 0, 0, width, height);
      if(record) {
        pgcolor.save("frames/frame"+floor(millis()/1000)+".tga");
      }
    }
    else {
      image(tmp, 0, 0, width, height);
    }
  }
}

void seedWithTex(RDLayer layer, String texpath) {
  PImage tex = loadImage(texpath);
  PGraphics pg = layer.get();
  pg.beginDraw();
  pg.resetShader();
  pg.background(0);
  pg.image(tex, 0, 0, layer.get().width, layer.get().height);
  pg.endDraw();
}

void seedWithTex(String texpath) {
  try {
    seedWithTex(l1, texpath);
    seedWithTex(l2, texpath);
    seedWithTex(l3, texpath);
  }
  catch (Exception e) {
    // just don't crash if the texture does not exist
  }
}

void setParamMap(String texpath) {
  PImage tex = loadImage(texpath);
  l1.texture = tex;
  l2.texture = tex;
  l3.texture = tex;
}

void saveState() {
  JSONArray state = new JSONArray();
  state.setJSONObject(0, l1.getParameterState());
  state.setJSONObject(1, l2.getParameterState());
  state.setJSONObject(2, l3.getParameterState());
  saveJSONArray(state, "data/state.json");
}

void loadState() {
  JSONArray state = loadJSONArray("data/state.json");
  l1.restoreParameterState(state.getJSONObject(0));
  l2.restoreParameterState(state.getJSONObject(1));
  l3.restoreParameterState(state.getJSONObject(2));
}

void keyPressed() {
  if(key == 'p') record = !record;
  if(key == 'x') {
    showUI = !showUI;
    cp5.setVisible(showUI);
  }
  if(key == 'y') {
    l1.clear(); l2. clear(); l3.clear();
  }
  if(key == 'c') colorizeit = !colorizeit;
  if(key == 'r') seedWithTex("data/texture.png");
  if(key == ' ') paused = !paused;
  if(key == 'n') blurEnabled = !blurEnabled;
  if(key == '1') mode = 1;
  if(key == '2') mode = 2;
  if(key == '3') mode = 3;
  if(key == 'z') zoom = !zoom;
  if(key == '#') saveState();
  if(key == '+') loadState();
}
