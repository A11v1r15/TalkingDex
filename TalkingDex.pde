import android.app.Activity; 
import android.os.Bundle; 
import android.speech.tts.TextToSpeech;
import java.util.Locale;

//.getString("name").replace("'", "").replace(":", "").replace(".", "").replace(" ", "-").replace("é", "e")

TextToSpeech t1;
float diameter;
ArrayList<PImage> list = new ArrayList<PImage>();
float cursor;
int pkn = 1;
JSONObject pkm;
int MaxDex = 898;

IntList alola;
IntList alolaUltra;
IntList galar;
IntList ioa;
IntList ct;
StringList versions;

void setup () {
  //size(400, 800);
  alola = new IntList(loadJSONArray("pkm/Alola.pkm").getIntArray());
  alolaUltra = new IntList(loadJSONArray("pkm/UltraAlola.pkm").getIntArray());
  galar = new IntList(loadJSONArray("pkm/Galar.pkm").getIntArray());
  ioa = new IntList(loadJSONArray("pkm/IoA.pkm").getIntArray());
  ct = new IntList(loadJSONArray("pkm/CT.pkm").getIntArray());
  versions = new StringList(loadJSONArray("pkm/Version.pkm").getStringArray());
  for (int i : ioa) {
    if (!galar.hasValue(i))
      galar.append(i);
  }
  for (int c : ct) {
    if (!galar.hasValue(c))
      galar.append(c);
  }
  alola.sort();
  alolaUltra.sort();
  galar.sort();
  diameter = (min(width, height)*0.7);
  imageMode(CENTER);
  t1 = new TextToSpeech(this.getActivity().getApplicationContext(), new TextToSpeech.OnInitListener() { 
    @Override public void onInit(int status) { 
      if (status != TextToSpeech.ERROR) {
        t1.setLanguage(Locale.UK);
      }
    }
  }
  );
  t1.setPitch(0.4f);
  diameter = (min(width, height)*0.7);
  for (int i = 1; i < MaxDex+1; i++) {
    list.add(loadImage(String.format("png/%03d.png", i)));
  }
  pkm = loadJSONObject(String.format("pkm/%03d.pkm", pkn));
  MaxDex = 151;
}

void draw() {
  checkMaxDex();
  drawFace();
  if (!changingVersion) dial(width/2, height/2, diameter/2);
  textSize(50);
  text(versions.get(versioN), width/3, height*0.9);
}

void dial(float x, float y, float r) {
  pushStyle();
  float w = x - mouseX;
  float h = y - mouseY;
  cursor = atan(h/w);
  if (w >= 0) cursor += PI;
  if (dialing) pkn = (int)map(cursor, -PI/2, PI+PI/2, 1, MaxDex);
  float iX, iY = 0;
  iX = x+cos(cursor)*r;
  iY = y+sin(cursor)*r;
  noStroke();
  fill(255, 100);
  if (dialing) {
    ellipse(iX, iY, r/2, r/2);
    image(list.get(index()-1), iX, iY, r/2, r/2);
  } else {
    stats(x, y-r*2, r/2);
    image(list.get(index()-1), x, y, r*2, r*2);
  }
  popStyle();
}

boolean dialing = false;
boolean changingVersion = false;
PVector touchStart = new PVector();

/*
void mousePressed() {
 touchStarted();
 }
 void mouseReleased() {
 touchEnded();
 }
 */
void touchStarted() {
  if (mouseY > height*0.8) {
    changingVersion = true;
    touchStart = new PVector(mouseX, mouseY);
  } else {
    dialing = true;
  }
}

void touchMoved() {
  if (changingVersion) {
    pkn = 1;
    int test = 0;
    if (touchStart.dist(new PVector(mouseX, mouseY)) > width/10) {
      test = (touchStart.x < mouseX)? 1 : -1;
      touchStart = new PVector(mouseX, mouseY);
    }
    test += versioN;
    if (test < 0)
      test += versions.size();
    if (test > versions.size()-1)
      test -= versions.size();
    versioN = test;
  }
}

int versioN;

void touchEnded() {
  boolean wasDialing = dialing;
  boolean wasChangingVersion = dialing;
  dialing = false;
  changingVersion = false;
  if (wasDialing) {
    pkm = loadJSONObject(String.format("pkm/%03d.pkm", index()));
    String entry = versions.get(versioN)+"Entry";
    t1.speak(pkm.getString("name") +". The"+pkm.getString("category")+". "+pkm.getString(entry).replace(".", ";"), TextToSpeech.QUEUE_FLUSH, null, null);
    //println(pkm.getString("name") +". The "+pkm.getString("category")+". "+pkm.getString(entry).replace(".", ";"));
  } else if (wasChangingVersion) {
  }
}

void stats(float x, float y, float r) {
  float map;
  beginShape();
  map = (float)pkm.getInt("hp"   )/255 * r;
  vertex(x + cos(TAU/12* 9) * map, y + sin(TAU/12* 9) * map);
  map = (float)pkm.getInt("atk"  )/255 * r;
  vertex(x + cos(TAU/12*11) * map, y + sin(TAU/12*11) * map);
  map = (float)pkm.getInt("dfs"  )/255 * r;
  vertex(x + cos(TAU/12* 1) * map, y + sin(TAU/12* 1) * map);
  map = (float)pkm.getInt("spatk")/255 * r;
  vertex(x + cos(TAU/12* 3) * map, y + sin(TAU/12* 3) * map);
  map = (float)pkm.getInt("spdfs")/255 * r;
  vertex(x + cos(TAU/12* 5) * map, y + sin(TAU/12* 5) * map);
  map = (float)pkm.getInt("spd"  )/255 * r;
  vertex(x + cos(TAU/12* 7) * map, y + sin(TAU/12* 7) * map);
  endShape();
  strokeWeight(1);
  noFill();
  for (float i = 0; i <= 1; i+=0.25) {
    stroke(255, 255*i);
    beginShape();
    vertex(x + cos(TAU/12* 9) * r*i, y + sin(TAU/12* 9) * r*i);
    vertex(x + cos(TAU/12*11) * r*i, y + sin(TAU/12*11) * r*i);
    vertex(x + cos(TAU/12* 1) * r*i, y + sin(TAU/12* 1) * r*i);
    vertex(x + cos(TAU/12* 3) * r*i, y + sin(TAU/12* 3) * r*i);
    vertex(x + cos(TAU/12* 5) * r*i, y + sin(TAU/12* 5) * r*i);
    vertex(x + cos(TAU/12* 7) * r*i, y + sin(TAU/12* 7) * r*i);
    endShape(CLOSE);
  }
  text("HP", x-10 + cos(TAU/12* 9) * r, y + sin(TAU/12* 9) * r);
  text("ATK", x-15 + cos(TAU/12*11) * r, y + sin(TAU/12*11) * r);
  text("DFS", x-15 + cos(TAU/12* 1) * r, y + sin(TAU/12* 1) * r);
  text("SPATK", x-25 + cos(TAU/12* 3) * r, y + sin(TAU/12* 3) * r);
  text("SPDFS", x-25 + cos(TAU/12* 5) * r, y + sin(TAU/12* 5) * r);
  text("SPD", x-15 + cos(TAU/12* 7) * r, y + sin(TAU/12* 7) * r);
}

void checkMaxDex() {  
  if (versioN < 3) {//RBY
    MaxDex = 151;
  } else if (versioN < 6) {//GSC
    MaxDex = 251;
  } else if (versioN < 11) {//RSE FrLg
    MaxDex = 386;
  } else if (versioN < 16) {//DPP HgSs
    MaxDex = 493;
  } else if (versioN < 20) {//BW BW2
    MaxDex = 649;
  } else if (versioN < 24) {//XY OrAs
    MaxDex = 721;
  } else if (versioN < 26) {//SM
    MaxDex = alola.size();
  } else if (versioN < 28) {//UsUm
    MaxDex = alolaUltra.size();
  } else if (versioN < 30) {//LGpe
    MaxDex = 153;
  } else if (versioN < 32) {//SwSh
    MaxDex = galar.size();
  }
}

int index() {
  if (versioN < 24) {//RBY GSC RSE FrLg DPP HgSs BW BW2 XY OrAs
    return pkn;
  } else if (versioN < 26) {//SM
    return alola.get(pkn-1);
  } else if (versioN < 28) {//UsUm
    return alolaUltra.get(pkn-1);
  } else if (versioN < 30) {//LGpe
    if (pkn <= 151)
      return pkn;
    return pkn+656;
  } else if (versioN < 32) {//SwSh
    return galar.get(pkn-1);
  }
  return pkn;
}

void drawFace() {
  pushMatrix();
  pushStyle();
  background (235, 107, 78);
  fill(185, 57, 28);
  noStroke();
  rect(0, height*0.8, width, height);
  noFill();
  strokeWeight(3);
  stroke(157, 29, 0);
  translate(width/2, height/2);
  pushMatrix();
  ellipse(0, 0, diameter, diameter);
  fill(255);
  rotate(radians(-45));
  translate(0, -diameter/2);
  rotate(radians(25));
  ellipse(0, 0, diameter/4, diameter * 0.7);
  stroke(15, 97, 95);
  line(diameter/8, 0, -diameter/8, 0);
  fill(115, 197, 195);
  ellipse(0, 0, diameter/8, diameter * 0.35);
  fill(255);
  stroke(157, 29, 0);
  popMatrix();
  rotate(radians(45));
  translate(0, -diameter/2);
  rotate(radians(-25));
  ellipse(0, 0, diameter/4, diameter * 0.7);
  stroke(15, 97, 95);
  line(diameter/8, 0, -diameter/8, 0);
  fill(115, 197, 195);
  ellipse(0, 0, diameter/8, diameter * 0.35);
  popMatrix();
  popStyle();
}

@Override
public void onDestroy() {
  super.onDestroy();
  if( t1 != null ) t1.shutdown();
}
