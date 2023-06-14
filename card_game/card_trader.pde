class CardTrader {
  ArrayList<Card> hand1;
  ArrayList<Card> hand2;

  boolean is_trading;
  private Card trading_card;

  void setHands(ArrayList<Card> hand1, ArrayList<Card> hand2) {
    this.hand1 = hand1;
    this.hand2 = hand2;
  }

  void begin(Card card) {
    is_trading = true;
    trading_card = card;
  }

  void end(Card card_to_trade) {
    int card1_idx = hand1.indexOf(trading_card);
    int card2_idx = hand2.indexOf(card_to_trade);


    hand1.add(card1_idx, card_to_trade);
    hand1.remove(trading_card);

    hand2.add(card2_idx, trading_card);
    hand2.remove(card_to_trade);

    is_trading = false;

    game_state.trade_lock = true;
  }


  void draw() {
    if (!is_trading) {
      return;
    }

    if (mouseButton == RIGHT) {
      is_trading = false;
      return;
    }

    for (Card c : this.hand2) {
      if (c.check_clicked()) {
        c.indicate_click();
        if (mouseButton == LEFT) {
          end(c);
          break;
        }
      }
    }

    strokeWeight(7);
    line(trading_card.x + IMG_W/2, trading_card.y + IMG_H/2, mouseX, mouseY);
    strokeWeight(1);
  }
}
