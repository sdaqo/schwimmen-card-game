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
    game_state.player_interactor.tradeCard(trading_card.id, card_to_trade.id);

    game_state.setTradeLock(true);
    is_trading = false;
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
