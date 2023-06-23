class GameState {
  ArrayList<Card> cards;
  ArrayList<Card> current_cards;
  ArrayList<Player> players;
  CardTrader card_trader;
  PlayerInteractions player_interactor;
  Client player_client;
  String server_addr;
  String room_id;
  String online_name;
  boolean is_online;
  private Player current_player;
  private boolean trade_lock;
  private boolean last_round;
  private GameStageContext game_stage_ctx;

  GameState(ArrayList<Player> players) {
    this.players = players;
    this.player_interactor = new PlayerInteractions();

    cards = load_cards();
    card_trader = new CardTrader();
    current_cards = new ArrayList<Card>();

    this.setGameStage(new MenuStageContext());
  }

  void setGameStage(GameStageContext stageCtx) {
    this.game_stage_ctx = stageCtx;
  }
  
  GameStageContext getGameStageCtx() {
    return game_stage_ctx;
  }

  void initNewRound() {
    // Change Game Stage
    this.setGameStage(new PlayingStageContext());
    
    // Return cards to the stack and assign new ones
    cards.addAll(current_cards);
    current_cards = randomHand();
    
    // Reset Players and give new hand
    for (Player p : players) {
      p.reset();
      p.addToHand(randomHand());
    }

    // Reset Stuff
    setTradeLock(false);
    setLastRound(false);
    
    // Start Game
    List<Player> living_players = players.stream()
      .filter(p -> p.health != 0)
      .collect(Collectors.toList());

    setPlayer(living_players.get(0));
    if (getPlayer().is_ai) {
      game_state.setGameStage(new AiStageContext());
      thread("ai_play");
    }
  }

  void initNewGame() {
    if (is_online) {
      if (!player_client.active()) {
        player_client.dispose();
        this.setGameStage(new ErrorStageContext("No Connection to the Server"));
      }
      
      rpcToServer("resetGame");
      this.setGameStage(new PlayerListOnlineStageContext());
    } else {
      this.setGameStage(new BeginStageContext());
    }
    for (Player p : players) {
      p.reset();
      p.health = 3;
    }
  }

  void setTradeLock(boolean is_locked) {
    this.trade_lock = is_locked;
  }

  boolean getTradeLock() {
    return trade_lock;
  }

  void setLastRound(boolean is_lastround) {
    this.last_round = is_lastround;
  }

  boolean getLastRound() {
    return last_round;
  }

  void setPlayer(Player player) {
    current_player = player;
  }

  Player getPlayer() {
    return current_player;
  }
  
  Card getCardFromID(int id) {
    for(Card card : cards) {
      if (card.id == id) {
        return card;
      }
    }
    
    println("Card with ID", id, "does not exsist");
    return null;
  }
}
