ArrayList<Card> load_cards() {
  File dir;
  dir = new File(sketchPath("data/images/cards"));
  
  File[] files = dir.listFiles();
  Arrays.sort(files);

  ArrayList<Card> loaded_cards = new ArrayList<Card>();

  int card_id = 0;

  // Add the cards
  for (File f : files) {
    // <value>_of_<type>.png
    String[] card_parts = split(f.getName(), "_");
    String card_value = card_parts[0];
    String card_type = card_parts[2].substring(0, card_parts[2].length() - 4);
    int card_value_numeric;

    try {
      card_value_numeric = Integer.parseInt(card_value);
    }
    catch(NumberFormatException e) {
      if (card_value.equals("ace")) {
        card_value_numeric = 11;
      } else {
        card_value_numeric = 10;
      }
    }

    String card_name = f.getName().substring(0, f.getName().length() - 4);
    PImage img = loadImage("data/images/cards/" + f.getName());
    
    loaded_cards.add(new Card(img, card_name, card_value_numeric, card_type, card_value, card_id));
    card_id++;
    
    loaded_cards.add(new Card(img, card_name, card_value_numeric, card_type, card_value, card_id));
    card_id++;
  }
  
  for (Card card : loaded_cards) {
    println(card.id);
  }
  return loaded_cards;
}

ArrayList<String> get_music_paths() {
  File dir;
  String[] file_extensions = new String[]{".mp3", ".wav", ".aiff", ".aif", ".aifc"};

  ArrayList<String> collected_music = new ArrayList<>();
  dir = new File(sketchPath("data/music"));

  for (File f : dir.listFiles()) {
    String name = f.getName();
    int lastIndexOf = name.lastIndexOf(".");
    if (lastIndexOf == -1) {
      continue;
    }
    if (Arrays.asList(file_extensions).contains(name.substring(lastIndexOf))) {
      collected_music.add("music/" + name);
    }
  }

  return collected_music;
}

ArrayList<Card> randomHand() {
  if (game_state.cards.size() <= 3) {
    throw new ArithmeticException("Amount of cards is < 3, can not give Hand");
  }

  ArrayList<Card> hand = new ArrayList<Card>();

  for (int i = 0; i < 3; i++) {
    int rand_idx = Math.round(random(0, game_state.cards.size() - 1));
    hand.add(game_state.cards.get(rand_idx));
    game_state.cards.remove(rand_idx);
  }

  return hand;
}


String sanetizeFloat(float num) {
  if (num == Math.round(num)) {
    return "" + Math.round(num);
  } else {
    DecimalFormat df = new DecimalFormat("#.#");
    return df.format(num);
  }
}



class AudioThread extends Thread {
  void run() {
    ArrayList<String> music = get_music_paths();
    if (music.size() == 0) {
      Thread.currentThread().interrupt();
    }
    while (!isInterrupted()) {
      int random_index = Math.round(random(0, music.size() - 1));
      SoundFile sound;
      
      try {
        sound = new SoundFile(APP, music.get(random_index));
        sound.play();
      } catch(Exception e) {
        continue;
      }
      while (true) {
        if (!sound.isPlaying()) {
          break;
        }

        try {
          Thread.sleep(1000);
        }
        catch (InterruptedException e) {
          sound.stop();
          Thread.currentThread().interrupt();
        }
      }
    }
  }
}
