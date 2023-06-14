class GameState {
  ArrayList<Card> cards;
  ArrayList<Card> current_cards;
  ArrayList<Player> players;
  CardTrader card_trader;
  PlayerInteractions player_interactor;
  Client player_client;
  String online_name;
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
    setPlayer(players.get(0));
    if (getPlayer().is_ai) {
      game_state.setGameStage(new AiStageContext());
      thread("ai_play");
    }
  }

  void initNewGame() {
    this.setGameStage(new BeginStageContext());
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
    return null;
  }
}
