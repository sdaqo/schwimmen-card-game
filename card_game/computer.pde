class Computer extends Player {
 
  Computer(String name) {
    super(name);
    this.is_ai = true;
  }
  
  
  @Override
  void play() {
    float current_cards_worth = calculate_hand_worth(game_state.current_cards);

    // Go through all possible options of changing cards
    float best_card_trade_value = 0;
    Card best_card_to_trade_from = null;
    Card best_card_to_trade = null;
    
    for(Card global_hand_card : game_state.current_cards) {
      for(Card hand_card : this.hand) {
        ArrayList temp_hand = new ArrayList<Card>(this.hand);        
        int card1_idx = temp_hand.indexOf(hand_card);

        temp_hand.add(card1_idx, global_hand_card);
        temp_hand.remove(hand_card);
        
        float worth = calculate_hand_worth(temp_hand);
        if (worth > best_card_trade_value) {
          best_card_trade_value = worth;
          best_card_to_trade_from = hand_card;
          best_card_to_trade = global_hand_card;
        }  
      }
    }
    
    if (best_card_trade_value > current_cards_worth) {
      game_state.card_trader.setHands(game_state.getPlayer().hand, game_state.current_cards);
      game_state.card_trader.begin(best_card_to_trade_from);
      game_state.card_trader.end(best_card_to_trade);
    } else {
      if (current_cards_worth > this.handWorth()) {
        game_state.player_interactor.tradeAllCards();
      } else {
        game_state.player_interactor.closeUp();
      }
    }
    
    try {
      Thread.sleep(1000);
    } catch (InterruptedException e) {
      Thread.currentThread().interrupt();
    } finally {
      game_state.player_interactor.endTurn();
    }
  }
}
