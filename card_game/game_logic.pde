class PlayerInteractions { //<>//
  void postprocess(String method_name, Object... params) {
  }

  void closeUp() {
    game_state.setLastRound(true);
    game_state.setTradeLock(true);
    game_state.getPlayer().is_closed = true;
    this.postprocess("closeUp");
  }

  void endTurn() {
    Player player = game_state.getPlayer();
    if (game_state.getLastRound()) {
      player.is_closed = true;
    }

    game_state.setTradeLock(false);

    boolean all_closed = true;
    for (Player p : game_state.players) {
      if (!p.is_closed) {
        all_closed  = false;
      }
    }


    if (all_closed || player.handWorth() >= 33) {
      end_round();
    } else {
      int current_player_index = game_state.players.indexOf(player);

      do {
        current_player_index++;

        if (current_player_index >= game_state.players.size()) {
          current_player_index = 0;
        }
      } while (game_state.players.get(current_player_index).is_closed ||
        game_state.players.get(current_player_index).health <= 0);

      game_state.setPlayer(game_state.players.get(current_player_index));
      game_state.card_trader.setHands(game_state.getPlayer().hand, game_state.current_cards);

      if (game_state.getPlayer().is_ai) {
        game_state.setGameStage(new AiStageContext());
        thread("ai_play");
      } else if (game_state.getPlayer().is_remote) {
        game_state.setGameStage(new RemotePlayerStageContext());
      } else {
        game_state.setGameStage(new PlayingStageContext());
      }
    }
    
    this.postprocess("endTurn");
  }


  void tradeAllCards() {
    ArrayList<Card> temp_cards = new ArrayList<Card>(game_state.current_cards);
    Collections.copy(game_state.current_cards, game_state.getPlayer().hand);
    game_state.getPlayer().hand = temp_cards;
    game_state.setTradeLock(true);
    this.postprocess("tradeAllCards");
  }

  void tradeCard(int id1, int id2) {
    // This is not ideal :)
   
    ArrayList<Card> hand1 = game_state.getPlayer().hand;
    ArrayList<Card> hand2 = game_state.current_cards;
    
    Card trading_card = game_state.getPlayer().getCardFromID(id1);
    Card card_to_trade = null;
    
    for (Card card :game_state.current_cards) {
      if (card.id == id2) {
        card_to_trade = card;
      }
    }
    
    
    int card1_idx = hand1.indexOf(trading_card);
    int card2_idx = hand2.indexOf(card_to_trade);

    hand1.add(card1_idx, card_to_trade);
    hand1.remove(trading_card);

    hand2.add(card2_idx, trading_card);
    hand2.remove(card_to_trade);
    
    game_state.setTradeLock(true);
    
    this.postprocess("tradeCard", id1, id2);
  }
}

class OnlinePlayerInteractions extends PlayerInteractions {
  @Override
  void postprocess(String method_name, Object... params) {
    rpcToServer(method_name, params);
  }
}



void end_round() {
  if (game_state.is_online) {
    game_state.setGameStage(new OnlineScoreboardStageContext());
  } else {
    game_state.setGameStage(new ScoreboardStageContext());
  }
  
  List<Player> sorted_players = new ArrayList<Player>(game_state.players);
  sorted_players.sort(Comparator.comparingDouble(Player::handWorth));
  sorted_players = sorted_players
    .stream().filter(p -> p.health != 0)
    .collect(Collectors.toList());

  int lastplayer_idx = game_state.players.indexOf(sorted_players.get(0));
  int first_player_idx = game_state.players.indexOf(sorted_players.get(sorted_players.size()-1));

  game_state.players.get(lastplayer_idx).health -= 1;
  game_state.players.get(first_player_idx).rounds_won += 1;

  if (game_state.players.stream().filter(plr -> plr.health != 0).count() <= 1) {
    end_game();
  }
}


void end_game() {
  game_state.setGameStage(new EndStageContext());
}


void ai_play() {
  game_state.getPlayer().play();
}


float calculate_hand_worth(ArrayList<Card> hand) {
  float worth = 0;
    
  List<String> card_ranks = hand
    .stream().map(Card::get_rank)
    .collect(Collectors.toList());

  List<String> card_types = hand
    .stream().map(Card::get_type)
    .collect(Collectors.toList());


  // Check if all ranks are the same -> 30.5 points
  if (card_ranks.stream().distinct().count() <= 1) {
    return 30.5f;
  }

  // Check if all cards are aces
  List distinct_types = card_types.stream().distinct().toList();
  if (distinct_types.size() <= 1 && distinct_types.get(0) == "ace") {
    return 33;
  }

  for (Card c : hand) {
    int type_freq = Collections.frequency(card_types, c.get_type());
    if (type_freq > 1) {
      for (int i = 0; i < card_types.size(); i++) {
        if (card_types.get(i).equals(c.get_type())) {
          worth = worth + hand.get(i).value;
        }
      }
      break;
    }
  }

  return worth;
}
