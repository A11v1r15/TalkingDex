import android.app.Activity; 
import android.os.Bundle; 
import android.speech.tts.TextToSpeech;
import java.util.Locale;

TextToSpeech t1;
float diameter;
ArrayList<PImage> list = new ArrayList<PImage>();
float cursor;
int pkn = 1;
JSONObject pkm;
int MaxDex = 893;

IntList alola;
IntList galar;
IntList ioa;

void setup () {
  //size(400, 800);
  alola = new IntList(loadJSONArray("UltraAlola.pkm").getIntArray());
  galar = new IntList(loadJSONArray("Galar.pkm").getIntArray());
  ioa = new IntList(loadJSONArray("IoA.pkm").getIntArray());
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
  diameter = (min(width, height)*0.7);
  for (int i = 1; i < MaxDex+1; i++) {
    list.add(loadImage(String.format("%03d.png", i)));
  }
  pkm = loadJSONObject(String.format("%03d.pkm", pkn));
}

void draw() {
  drawFace();
  dial(width/2, height/2, diameter/2);
}

void dial(float x, float y, float r) {
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
    image(list.get(pkn-1), iX, iY, r/2, r/2);
  } else {
    stats(x, y-r*2, r/2);
    image(list.get(pkn-1), x, y, r*2, r*2);
  }
}

boolean dialing = false;
/*
void mousePressed() {
 touchStarted();
 }
 void mouseReleased() {
 touchEnded();
 }
 */
void touchStarted() {
  dialing = true;
}
void touchEnded() {
  t1.setPitch(0.4f);
  dialing = false;
  JSONObject pkm = loadJSONObject(String.format("%03d.pkm", pkn));
  String entry;
  if (galar.hasValue(pkn) || pkn == 808 || pkn == 809) {
    entry = "SwordEntry";
  } else if (alola.hasValue(pkn)) {
    entry = "UltraSunEntry";
  } else {
    entry = "XEntry";
  }
  t1.speak(pkm.getString("name") +". The"+pkm.getString("category")+". "+pkm.getString(entry).replace(".", ";"), TextToSpeech.QUEUE_FLUSH, null, null);
  //println(pkm.getString("name") +". The "+pkm.getString("category")+". "+pkm.getString(entry).replace(".", ";"));
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

void drawFace() {
  pushMatrix();
  background (235, 107, 78);
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
}
