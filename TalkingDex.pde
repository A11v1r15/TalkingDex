import android.app.Activity; 
import android.os.Bundle; 
import android.speech.tts.TextToSpeech;
import android.speech.tts.Voice;
import android.content.SharedPreferences;
import java.util.Locale;
import java.util.Set;

//.getString("name").replace("'", "").replace(":", "").replace(".", "").replace(" ", "-").replace("é", "e")

TextToSpeech t1;
Voice vF;
Voice vM;
SharedPreferences preferences;
SharedPreferences.Editor preferencesEditor;

float diameter;
float fontSize = 50;

ArrayList<PImage> list = new ArrayList<PImage>();
float cursor;
int pkn = 1;
JSONObject pkm;
int MaxDex = 905;

IntList alolan;
IntList galarian;
IntList hisuian;
IntList mega;
IntList gigantamax;
IntList alola;
IntList alolaUltra;
IntList galar;
IntList hisui;
StringList versions;
JSONObject colours;

String[] names = new String[MaxDex];

void setup () {
  //size(400, 800);
  JSONObject pokedex = loadJSONObject("pkm/Pokedex.pkm");
  colours = loadJSONObject("pkm/Colour.pkm");
  galar      = new IntList(pokedex.getJSONArray("Galar Available").getIntArray());
  hisui     = new IntList(pokedex.getJSONArray("Hisui").getIntArray());
  alola      = new IntList(pokedex.getJSONArray("Alola").getIntArray());
  alolaUltra = new IntList(pokedex.getJSONArray("Ultra Alola").getIntArray());
  versions = new StringList(loadJSONArray("pkm/Version.pkm").getStringArray());
  alola.sort();
  alolaUltra.sort();
  galar.sort();
  hisui.sort();
  preferences = this.getActivity().getApplicationContext().getSharedPreferences("com.a11v1r15.talkingdex.SharedPref", 0);
  preferencesEditor = preferences.edit();
  versioN = preferences.getInt("versioN", 0);
  diameter = (min(width, height)*0.7);
  imageMode(CENTER);
  t1 = new TextToSpeech(this.getActivity().getApplicationContext(), new TextToSpeech.OnInitListener() {
    @Override public void onInit(int status) { 
      if (status != TextToSpeech.ERROR) {
        t1.setLanguage(Locale.UK);
        vF = t1.getVoice();
        for (Voice tmpVoice : t1.getVoices()) {
          if(tmpVoice.getName().equals("en-gb-x-rjs-local")){
           vM = tmpVoice;
           break;
          }
        }
      }
    }
  }, "com.google.android.tts"
  );
  t1.setPitch(0.4f);
  diameter = (min(width, height)*0.7);
  for (int i = 1; i <= MaxDex; i++) {
    list.add(loadImage(String.format("png/%04d.png", i)));
    pkm = loadJSONObject(String.format("pkm/%04d.pkm", i));
    names[i-1] = pkm.getString("name");
  }
  pkm = loadJSONObject(String.format("pkm/%04d.pkm", pkn));
}

void draw() {
  checkMaxDex();
  drawFace();
  dial(width/2, height/2, diameter/2);
  textSize(fontSize);
  textAlign(CENTER);
  text(versions.get(versioN), width/2, height*0.95 + fontSize/2);
  text("<", width*0.1, height*0.95 + fontSize/2);
  text(">", width*0.9, height*0.95 + fontSize/2);
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
  textAlign(CENTER);
  imageMode(CENTER);
  if (dialing) {
    ellipse(iX, iY, r/2, r/2);
    image(list.get(index()-1), iX, iY, r/2, r/2);
    text(index(), x, y-r/2);
    text(names[pkn-1], x, y + r * 1.5);
  } else {
    stats(x, y-r*2, r/2);
    pkm = loadJSONObject(String.format("pkm/%04d.pkm", index()));
    noStroke();
    if (pkm.getString("type2") == "") {
      fill(unhex("FF" + colours.getString(pkm.getString("type1"))));
      rect(x-r/2, y-.1*r, r, r, r/4, r/4, r/4, r/4);
    } else {
      fill(unhex("FF" + colours.getString(pkm.getString("type1"))));
      rect(x-r/2, y-.1*r, r/2, r, r, 0, 0, r);
      fill(unhex("FF" + colours.getString(pkm.getString("type2"))));
      rect(x, y-.1*r, r/2, r, 0, r, r, 0);
    }
    fill(255, 100);
    textAlign(CENTER);
    text(index(), x, y-r/2);
    String nameAbilities = pkm.getString("name") + "\n" +
                            pkm.getString("ability1") + (pkm.getString("ability2")!=""?"/"+pkm.getString("ability2"):"") + "\n" +
                            pkm.getString("abilityHidden");
    text(nameAbilities, x, y + r * 1.2 + fontSize*2);
    image(list.get(index()-1), x, y, r*2, r*2);
  }
  popStyle();
}

boolean dialing = false;
boolean centerTouch = false;
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
  touchStart = new PVector(mouseX, mouseY);
  if (mouseY > height*0.9) {
    if ((mouseX < width*0.2)||(mouseX > width*0.8)) {
      pkn = 1;
      if (mouseX < width*0.2) {
        versioN = loopInArrayBounds(versioN - 1, versions.size());
      } else if (mouseX > width*0.8) {
        versioN = loopInArrayBounds(versioN + 1, versions.size());
      }
      preferencesEditor.putInt("versioN", versioN);
      preferencesEditor.apply();
    }
  } else {
    if (diameter < PVector.dist(touchStart, new PVector(width/2, height/2)) * 2)
      dialing = true;
    else
      centerTouch = true;
  }
}

void touchMoved() {
}

int versioN;

void touchEnded() {
  if (dialing || centerTouch) {
    pkm = loadJSONObject(String.format("pkm/%04d.pkm", index()));
    String entry = versions.get(versioN)+"Entry";
    //println(pkm.getString("name") +". The "+pkm.getString("category")+". "+pkm.getString(entry).replace(".", ";"));
    if (versioN == 34) {t1.setPitch(1f); t1.setVoice(vM);} else {t1.setPitch(0.4f); t1.setVoice(vF);}
    t1.speak(pkm.getString("name") +". The"+pkm.getString("category")+". "+pkm.getString(entry).replace(".", ";"), TextToSpeech.QUEUE_FLUSH, null, null);
  }
  dialing = false;
  centerTouch = false;
}

void stats(float x, float y, float r) {
  float map;
  beginShape();
  map = (float)pkm.getInt("HP" )/255 * r;
  vertex(x + cos(TAU/12* 9) * map, y + sin(TAU/12* 9) * map);
  map = (float)pkm.getInt("Atk")/255 * r;
  vertex(x + cos(TAU/12*11) * map, y + sin(TAU/12*11) * map);
  map = (float)pkm.getInt("Def")/255 * r;
  vertex(x + cos(TAU/12* 1) * map, y + sin(TAU/12* 1) * map);
  map = (float)pkm.getInt("SpA")/255 * r;
  vertex(x + cos(TAU/12* 3) * map, y + sin(TAU/12* 3) * map);
  map = (float)pkm.getInt("SpD")/255 * r;
  vertex(x + cos(TAU/12* 5) * map, y + sin(TAU/12* 5) * map);
  map = (float)pkm.getInt("Spe")/255 * r;
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
  textAlign(CENTER);
  text("HP" , x + cos(TAU/12* 9) * r, y + sin(TAU/12* 9) * r);
  text("SpA", x + cos(TAU/12* 3) * r, y + sin(TAU/12* 3) * r + fontSize);
  textAlign(LEFT);
  text("Atk", x + cos(TAU/12*11) * r, y + sin(TAU/12*11) * r + fontSize/2);
  text("Def", x + cos(TAU/12* 1) * r, y + sin(TAU/12* 1) * r + fontSize/2);
  textAlign(RIGHT);
  text("Spe", x + cos(TAU/12* 7) * r, y + sin(TAU/12* 7) * r + fontSize/2);
  text("SpD", x + cos(TAU/12* 5) * r, y + sin(TAU/12* 5) * r + fontSize/2);
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
  } else if (versioN < 34) {//BdSp
    MaxDex = 493;
  } else if (versioN < 35) {//La
    MaxDex = hisui.size();
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
  } else if (versioN < 34) {//BdSp
    return pkn;
  } else if (versioN < 35) {//La
    return hisui.get(pkn-1);
  }
  return pkn;
}

void drawFace() {
  pushMatrix();
  pushStyle();
  background (235, 107, 78);
  fill(unhex("FF" + colours.getString(versions.get(versioN))));
  noStroke();
  rect(0, height*0.9, width, height);
  fill(157, 29, 0);
  rect(width*0.8, height*0.9, width, height);
  rect(0, height*0.9, width*0.2, height);
  strokeWeight(3);
  translate(width/2, height/2);
  pushMatrix();
  stroke(15, 97, 95);
  fill(115, 197, 195);
  ellipse(0, 0, diameter * 1.2, diameter * 1.2);
  fill(243, 165, 147);
  ellipse(0, 0, diameter, diameter);
  fill(255);
  rotate(radians(-45));
  translate(0, -diameter/2);
  rotate(radians(25));
  ellipse(0, 0, diameter/4, diameter * 0.7);
  line(diameter/8, 0, -diameter/8, 0);
  fill(115, 197, 195);
  ellipse(0, 0, diameter/8, diameter * 0.35);
  fill(255);
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

int loopInArrayBounds(int n, int max) {
  if (n >= max)
    return n - max;
  if (n < 0)
    return max - n - 2;
  return n;
}

@Override
  public void onDestroy() {
  super.onDestroy();
  if ( t1 != null ) t1.shutdown();
}
