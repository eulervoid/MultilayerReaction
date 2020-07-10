class RDLayer {

  int id;
  PGraphics layer;
  PShader reaction;
  PImage texture;
  Slider dA, dB, feed, kill, flow, noiseamt, noisesize, noisemv, alpha;
  Toggle brush;
  
  RDLayer(int id, int w, int h) {
    this.id = id;
    reaction = loadShader("data/reaction.frag");
    layer = createGraphics(w, h, P3D);
    layer.noSmooth();
  }
  
  PGraphics get() {
    return layer;
  }
  
  void draw() {
    updateReactionParameters();
    layer.beginDraw();
    layer.shader(reaction);
    layer.rect(0, 0, layer.width, layer.height);
    layer.endDraw();
  }
  
  void add(PGraphics other) {
    layer.beginDraw();
    layer.tint(255, alpha.getValue()*255);
    layer.image(other, 0, 0, layer.width, layer.height);
    layer.endDraw();
  }
  
  void updateReactionParameters() {
    reaction.set("dA", dA.getValue());
    reaction.set("dB", dB.getValue());
    reaction.set("feed", feed.getValue());
    reaction.set("kill", kill.getValue());
    reaction.set("noiseamt", noiseamt.getValue());
    reaction.set("noisemv", noisemv.getValue());
    reaction.set("noisesize", noisesize.getValue());
    reaction.set("flow", flow.getValue());
    reaction.set("resolution", float(layer.width), float(layer.height));
    reaction.set("brush", brush.getValue());
    reaction.set("texture", texture);
  }
  
  void addSliders(ControlP5 cp5, float x, float y) {
    dA = cp5.addSlider("dA"+id).setPosition(x,y).setSize(200,10).setRange(0,1.).setValue(1.);
    dB = cp5.addSlider("dB"+id).setPosition(x,y+20).setSize(200,10).setRange(0,1.).setValue(.5);
    feed = cp5.addSlider("feed"+id).setPosition(x,y+40).setSize(200,10).setRange(0,.1).setValue(.0545);
    kill = cp5.addSlider("kill"+id).setPosition(x,y+60).setSize(200,10).setRange(0,.1).setValue(.0443);
    flow = cp5.addSlider("flow"+id).setPosition(x,y+80).setSize(200,10).setRange(0,2.).setValue(1.);
    noiseamt = cp5.addSlider("noiseamt"+id).setPosition(x,y+110).setSize(200,10).setRange(0,.2).setValue(.01);
    noisemv = cp5.addSlider("noisemv"+id).setPosition(x,y+130).setSize(200,10).setRange(0,2.).setValue(.2);
    noisesize = cp5.addSlider("noisesize"+id).setPosition(x,y+150).setSize(200,10).setRange(10,.5).setValue(2.);
    alpha = cp5.addSlider("alpha"+id).setPosition(x,y+170).setSize(200,10).setRange(0,.2).setValue(0);
    brush = cp5.addToggle("brush"+id).setPosition(x,y+190).setSize(10, 10).setValue(true);
  }
  
  JSONObject getParameterState() {
    JSONObject params = new JSONObject();
    params.setFloat("dA", dA.getValue());
    params.setFloat("dB", dB.getValue());
    params.setFloat("feed", feed.getValue());
    params.setFloat("kill", kill.getValue());
    params.setFloat("flow", flow.getValue());
    params.setFloat("noiseamt", noiseamt.getValue());
    params.setFloat("noisemv", noisemv.getValue());
    params.setFloat("noisesize", noisesize.getValue());
    params.setFloat("alpha", alpha.getValue());
    params.setFloat("brush", brush.getValue());
    return params;
  }
  
  void restoreParameterState(JSONObject params) {
    dA.setValue(params.getFloat("dA"));
    dB.setValue(params.getFloat("dB"));
    feed.setValue(params.getFloat("feed"));
    kill.setValue(params.getFloat("kill"));
    flow.setValue(params.getFloat("flow"));
    noiseamt.setValue(params.getFloat("noiseamt"));
    noisemv.setValue(params.getFloat("noisemv"));
    noisesize.setValue(params.getFloat("noisesize"));
    alpha.setValue(params.getFloat("alpha"));
    brush.setValue(params.getFloat("brush"));
  }
  
  void clear() {
    layer.beginDraw();
    layer.background(255, 0, 0);
    layer.endDraw();
  }
  
}
