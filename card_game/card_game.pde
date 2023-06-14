import processing.net.*;
import processing.sound.*;
import java.lang.reflect.Method;
import java.io.File;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import java.util.Comparator;
import java.text.DecimalFormat;
import java.lang.reflect.Method;
import java.lang.reflect.InvocationTargetException;
import java.util.Arrays;


int IMG_H = 300;
int IMG_W = 200;
int SPACING = -30;
int FRAMERATE = 60;
PApplet APP = this;


PImage cardBack;
PImage heart;
PImage heart_outline;
AudioThread audio_thread = new AudioThread();

GameState game_state;

public void setup() {
  size(1280, 800);
  frameRate(FRAMERATE);
  
  surface.setResizable(true);
  surface.setTitle("Schwimmen Card Game");
  
  println("Loading Game...");

  ArrayList<Player> players = new ArrayList<Player>();

  game_state = new GameState(players);


  cardBack = loadImage("images/card_back.png");
  heart = loadImage("images/heart.png");
  heart_outline = loadImage("images/heart-outline.png");
  
  audio_thread.start();
  println("Finished Loading!");
}


void draw() {
  game_state.getGameStageCtx().draw();
}

void mouseClicked() {
  game_state.getGameStageCtx().mouseClicked();
}

void keyTyped() {
  game_state.getGameStageCtx().keyTyped();
}

void windowResized() {
  game_state.getGameStageCtx().windowResized();
}
