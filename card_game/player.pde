class Player {
  String name;
  ArrayList<Card> hand;
  int rounds_won;
  int health;
  boolean is_closed;
  boolean is_ai = false;
  boolean is_remote = false;


  Player(String name) {
    this.name = name;
    this.health = 3;
    this.hand = new ArrayList<Card>();
    this.is_closed = false;
    this.rounds_won = 0;
  }

  void reset() {
    game_state.cards.addAll(hand);
    hand = new ArrayList<Card>();
    rounds_won = 0;
    is_closed = false;
  }
  void addToHand(Card card) {
    this.hand.add(card);
  }

  void addToHand(Collection<Card> card) {
    this.hand.addAll(card);
  }

  void removeFromHand(Card card) {
    game_state.cards.add(card);
    this.hand.remove(card);
  }

  void renderHand(int x, int y, boolean flipped) {
    for (Card c : this.hand) {
      c.render(x, y, flipped);
      x = x + IMG_W + SPACING;
    }
  }

  void renderHealth(int x, int y, int heart_w) {
    int offset = x;

    for (int i = 0; i<this.health; i++) {
      image(heart, offset, y, heart_w, heart_w);
      offset = offset + heart_w;
    }

    for (int i = 0; i<3 - this.health; i++) {
      image(heart_outline, offset, y, heart_w, heart_w);
      offset = offset + heart_w;
    }
  }

  float handWorth() {
    return calculate_hand_worth(this.hand);
  }

  void play() {
  }
}

class RemotePlayer extends Player {  
  RemotePlayer(String name, List<Integer> deck_card_ids) {
    super(name);
    this.is_remote = true;
    for(int id : deck_card_ids) {
      Card card = game_state.getCardFromID(id);
      this.addToHand(card);
      game_state.cards.remove(card);
    }
  }
}
