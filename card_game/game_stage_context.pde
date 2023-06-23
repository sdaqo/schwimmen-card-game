class GameStageContext {
  ArrayList<Button> buttons;
  ArrayList<TextInput> inputs;

  private GameStageContext() {
    this.buttons = new ArrayList<Button>();
    this.inputs = new ArrayList<TextInput>();
    this.initUI();
  }

  void renderUI() {
    for (Button b : this.buttons) {
      b.render();
    }
    for (TextInput ti : this.inputs) {
      ti.render();
    }
  }

  void initUI() {
  }
  void draw() {
  }

  void keyTyped() {
    for (TextInput ti : this.inputs) {
      ti.checkInput();
    }
  }

  void mouseClicked() {
    if (mouseButton != LEFT) {
      return;
    }

    for (Button b : this.buttons) {
      b.checkAndCall();
    }

    for (TextInput ti : this.inputs) {
      ti.checkFocus();
    }
  }

  void windowResized() {
    // Reinitalize Buttons so they fit properly into the window
    this.buttons = new ArrayList<Button>();
    this.inputs = new ArrayList<TextInput>();
    this.initUI();
  }
}

class PlayingStageContext extends GameStageContext {
  @Override
    void initUI() {
    OnBtnClickEventListener trade_all_cads_event = () -> {
      if (game_state.getTradeLock()) {
        return;
      }
      game_state.player_interactor.tradeAllCards();
    };

    OnBtnClickEventListener end_turn_event = () -> {
      if (game_state.getTradeLock()) {
        game_state.player_interactor.endTurn();
      }
    };

    OnBtnClickEventListener close_up_event = () -> {
      game_state.player_interactor.closeUp();
    };


    this.buttons.add(new Button(width/2-160, 500, 320, 50, "Trade whole Hand", trade_all_cads_event));
    this.buttons.add(new Button(width-270, height-70, 250, 50, "End Round", end_turn_event));
    this.buttons.add(new Button(width/2-100, height-70, 200, 50, "Close Hand", close_up_event));
  }

  void renderPlayerlist(int x, int y) {
    textSize(30);
    textAlign(LEFT, CENTER);
    fill(240, 240, 240);

    text("Next Players:", x, y);


    // Render All Players that are not the current player, sorted by who comes next
    List<Player> left = game_state.players.subList(0, game_state.players.indexOf(game_state.getPlayer()));
    List<Player> right = game_state.players.subList(game_state.players.indexOf(game_state.getPlayer()) + 1, game_state.players.size());

    y += 30;
    x += 20;

    for (Player p : right) {
      if (p.is_closed || p.health == 0) {
        continue;
      }
      text(p.name, x, y);
      int offset = Math.round(textWidth(p.name)) + 15;
      p.renderHealth(x + offset, y - 6, 25);
      y += 40;
    }

    for (Player p : left) {
      if (p.is_closed || p.health == 0) {
        continue;
      }
      text(p.name, x, y);
      int offset = Math.round(textWidth(p.name)) + 15;
      p.renderHealth(x + offset, y - 6, 25);
      y += 40;
    }
  }



  @Override
    void draw() {
    background(60, 72, 107);

    Player player = game_state.getPlayer();

    fill(240, 240, 240);
    textSize(30);
    text("Current Player: " + player.name, 10, 30);
    text("Deck Worth: " + sanetizeFloat(player.handWorth()), 10, 60);

    renderPlayerlist(10, 130);

    if (game_state.getLastRound()) {
      text("Last Round!", width/2-textWidth("Last Round!")/2, 20);
    }

    // Render Current Cards
    int x_pos = width/2-(IMG_W*3/2);
    for (Card c : game_state.current_cards) {
      c.render(x_pos, height/10, false);
      x_pos += IMG_W;
    }

    // Render Player Hand and Health
    int handWidth = (IMG_W * 3) + (SPACING * 3);
    player.renderHand(width/2-handWidth/2, 600, player.is_closed);
    game_state.getPlayer().renderHealth(width-150, 0, 50);

    // Render Buttons
    this.renderUI();

    if (game_state.card_trader.is_trading) {
      game_state.card_trader.draw();
    }

    if (mousePressed) {
      Card clicked_card = null;
      for (int i = game_state.getPlayer().hand.size() - 1; i >= 0; i--) {
        Card c = game_state.getPlayer().hand.get(i);
        if (c.check_clicked()) {
          clicked_card = c;
          break;
        }
      }

      if (clicked_card != null) {
        if (mouseButton == LEFT) {

          if (!game_state.getTradeLock()) {
            game_state.card_trader.setHands(game_state.getPlayer().hand, game_state.current_cards);
            game_state.card_trader.begin(clicked_card);
          }
        } else {
          clicked_card.indicate_click();
        }
      }
    }
  }
}


class ScoreboardStageContext extends GameStageContext {
  @Override
    void initUI() {
    OnBtnClickEventListener next = () -> {
      game_state.initNewRound();
    };

    this.buttons.add(new Button(width/2-100, height-70, 200, 50, "Next Round", next));
  }

  @Override
    void draw() {
    background(60, 72, 107);

    this.renderUI();
    textSize(60);
    int x = width/2 - Math.round(textWidth("Scoreboard"))/2;
    int y = width/4;

    textAlign(LEFT, CENTER);
    fill(240, 240, 240);

    text("Scoreboard", x, y);
    textSize(37);
    List<Player> sorted_players = new ArrayList<Player>(game_state.players);
    sorted_players.sort(Comparator.comparingDouble(Player::handWorth));
    Collections.reverse(sorted_players);

    sorted_players = sorted_players
      .stream().filter(p -> p.health != 0)
      .collect(Collectors.toList());
    y += 60;
    x += 20;

    for (Player p : sorted_players) {
      text(p.name, x, y);
      int offset = Math.round(textWidth(p.name)) + 15;
      p.renderHealth(x + offset, y - 6, 25);
      text(sanetizeFloat(p.handWorth()), x + offset + 25*3.5, y);
      y += 40;
    }
  }
}

class OnlineScoreboardStageContext extends ScoreboardStageContext {
  boolean is_player_ready = false;
  
  class RpcInterface {

    // Update cards of players here
    void setPlayerList(List<String> names, List<List<Integer>> card_ids) {
      Map<String, List<Integer>> pl_map = IntStream.range(0, names.size()).boxed()
        .collect(Collectors.toMap(names::get, card_ids::get));

      for (Player pl : game_state.players) {
        if (!pl_map.containsKey(pl.name)) {
          continue;
        }

        pl.reset();

        List<Card> cards = new ArrayList<>();
        for (int id : pl_map.get(pl.name)) {
          Card card = game_state.getCardFromID(id);
          cards.add(card);
          game_state.cards.remove(card);
        }

        pl.addToHand(cards);
      }
    }

    void startGame(List<Integer> global_deck) {
      game_state.cards.addAll(game_state.current_cards);
      game_state.current_cards = new ArrayList<Card>();
      
      for ( int id : global_deck ) {
        Card card = game_state.getCardFromID(id);
        game_state.current_cards.add(card);
      }

      game_state.setTradeLock(false);
      game_state.setLastRound(false);

      game_state.player_interactor = new OnlinePlayerInteractions();

      game_state.setPlayer(game_state.players.get(0));

      Player curr_player = game_state.getPlayer();

      if (curr_player.is_remote) {
        game_state.setGameStage(new RemotePlayerStageContext());
      } else if (curr_player.is_ai) {
        game_state.setGameStage(new AiStageContext());
        thread("ai_play");
      } else {
        game_state.setGameStage(new PlayingStageContext());
      }
    }
    
    void playerLeave(String name) {
      for (Player pl : game_state.players) {
        if (!pl.name.equals(name)) {
          continue;
        }

        pl.reset();
        game_state.players.remove(pl);
      }
    }
  }


  @Override
    void initUI() {
    OnBtnClickEventListener next = () -> {
      is_player_ready = true;
      rpcToServer("nextRound");
    };

    this.buttons.add(new Button(width/2-100, height-70, 200, 50, "Next Round", next));
  }

  @Override
  void draw() {
    super.draw();
    
    if (is_player_ready) {
      textSize(22);
      text("You are Ready", width/2-textWidth("You are Ready")/2, height-90);
    }
    
    if (game_state.player_client.available() > 0) {
      String json = game_state.player_client.readStringUntil(125); // }
      if (json==null) {
        return;
      }
      Object ret;

      try {
        ret = invokeJsonRPC(json, RpcInterface.class, new RpcInterface());
      }
      catch(Exception e) {
        println(e.getMessage());
        return;
      }
    }
  }
}

class BeginStageContext extends GameStageContext {
  String name = "";

  @Override
    void initUI() {
    OnBtnClickEventListener add_player = () -> {
      game_state.players.add(new Player(this.name));
      this.name = "";
    };

    OnBtnClickEventListener add_computer = () -> {
      game_state.players.add(new Computer(this.name));
      this.name = "";
    };

    OnBtnClickEventListener begin_game = () -> {
      if (game_state.players.size() <= 0) {
        return;
      }
      game_state.initNewRound();
    };

    OnBtnClickEventListener back = () -> {
      game_state.players = new ArrayList<Player>();
      this.name = "";
      game_state.setGameStage(new MenuStageContext());
    };

    this.buttons.add(new Button(10, height-70, 200, 50, "Back", back));
    this.buttons.add(new Button(width/2-210, height-70, 200, 50, "New Player", add_player));
    this.buttons.add(new Button(width/2+10, height-70, 200, 50, "New PC", add_computer));
    this.buttons.add(new Button(width-270, height-70, 250, 50, "Start Game", begin_game));
  }

  @Override
    void draw() {
    background(60, 72, 107);
    this.renderUI();
    text("Name (Type it): " + this.name, width/2-textWidth("Name (Type it): " + this.name)/2, height-100);

    textAlign(LEFT, CENTER);
    fill(240, 240, 240);
    textSize(37);
    int x = width/2 - 40;
    int y = 50;

    for (Player p : game_state.players) {
      text(p.name, x, y);
      int offset = Math.round(textWidth(p.name)) + 15;
      p.renderHealth(x + offset, y - 6, 25);
      y += 40;
    }
  }

  @Override
    void keyTyped() {
    // 8 == Backspace
    if (int(key) == 8) {
      if (name.length() > 0) {
        name = name.substring(0, name.length() - 1);
      }
    } else if (int(key) == 10) {
      game_state.players.add(new Player(name));
      name = "";
    } else {
      name += key;
    }
  }
}

class AiStageContext extends GameStageContext {
  @Override
    void draw() {
    fill(45, 45, 45, 90);
    rect(0, 0, width, height);

    ArrayList<Card> current_cards = new ArrayList<Card>(game_state.current_cards);

    int x_pos = width/2-(IMG_W*3/2);
    for (Card c : current_cards) {
      c.render(x_pos, height/10, false);
      x_pos += IMG_W;
    }


    fill(240, 240, 240);
    textSize(60);
    String ai_name = game_state.getPlayer().name;
    text(ai_name + " is currently playing...", width/2-textWidth(ai_name + " is currently playing...")/2, height/2);
  }
}

class EndStageContext extends GameStageContext {
  @Override
    void initUI() {
    OnBtnClickEventListener back_to_menu = () -> {
      if (game_state.is_online) {
        game_state.player_client.dispose();
      }
      game_state.setGameStage(new MenuStageContext());
    };

    OnBtnClickEventListener new_game = () -> {
      game_state.initNewGame();
    };

    this.buttons.add(new Button(width/2-210, height-70, 200, 50, "New Game", new_game));
    this.buttons.add(new Button(width/2+10, height-70, 200, 50, "Menu", back_to_menu));
  }

  @Override
    void draw() {
    background(60, 72, 107);

    this.renderUI();
    textSize(60);
    int x = width/2 - Math.round(textWidth("Winner"))/2;
    int y = width/4;

    textAlign(LEFT, CENTER);
    fill(240, 240, 240);

    text("Winner", x, y);
    textSize(37);

    Player winner = game_state.players.stream()
      .filter(player -> player.health != 0)
      .sorted((p1, p2) -> Integer.compare(p1.rounds_won, p2.rounds_won))
      .collect(Collectors.toList())
      .get(0);

    y += 60;
    x += 20;

    text(winner.name, x, y);
    int offset = Math.round(textWidth(winner.name)) + 15;
    winner.renderHealth(x + offset, y - 6, 25);
  }
}


class BeginOnlineStageContext extends GameStageContext {
  String address = "127.0.0.1:6969";
  String ip = "";
  String player_name = "";
  int port = 0;
  String room_id = "";
  String errstr = "";

  private boolean checkAddress() {
    String[] addr_parts = split(address, ":");
    if (addr_parts.length != 2) {
      errstr = "Address is not valid";
      return false;
    }

    int server_port = 0;
    try {
      server_port = Integer.parseInt(addr_parts[1]);
    }
    catch(NumberFormatException e) {
      errstr = "Address is not valid";
      return false;
    }
    println(addr_parts[0], server_port);
    Client dummy_client = new Client(APP, addr_parts[0], server_port);
    if (!dummy_client.active()) {
      errstr = "Can not connect to this server";
      return false;
    }
    errstr = "Connected!";
    dummy_client.dispose();

    return true;
  }

  private void parseAddr() {
    String[] addr_parts = split(address, ":");
    this.ip = addr_parts[0];
    this.port = Integer.parseInt(addr_parts[1]);
  }


  @Override
    void initUI() {
    OnBtnClickEventListener back = () -> {
      game_state.players = new ArrayList<Player>();
      game_state.setGameStage(new MenuStageContext());
    };

    OnBtnClickEventListener host_game = () -> {
      if (!checkAddress()) {
        return;
      }

      parseAddr();
      if (room_id.length() == 0 || player_name.length() == 0) {
        errstr = "Please Specify the Room ID and/or Player Name";
        return;
      }

      game_state.player_client = new Client(APP, ip, port);
      rpcToServer("createRoom", room_id);
      rpcToServer("joinRoom", room_id, player_name);
      
      game_state.server_addr = address;
      game_state.room_id = room_id;
      
      game_state.setGameStage(new PlayerListOnlineStageContext());
    };

    OnBtnClickEventListener join_game = () -> {
      if (!checkAddress()) {
        return;
      }

      parseAddr();

      game_state.player_client = new Client(APP, ip, port);
      rpcToServer("joinRoom", room_id, player_name);
      
      game_state.server_addr = address;
      game_state.room_id = room_id;
      
      game_state.setGameStage(new PlayerListOnlineStageContext());
    };

    InputEventListener server_address = (String addr) -> {
      this.address = addr;
    };

    InputEventListener room_id = (String id) -> {
      this.room_id = id;
    };

    InputEventListener name = (String pname) -> {
      this.player_name = pname;
      game_state.online_name = pname;
    };

    textSize(30);
    this.inputs.add(new TextInput(width/2-(int)textWidth("Server Address (ip:port): ")/2, height/2, "Server Address (ip:port): ", server_address));
    this.inputs.add(new TextInput(width/2-(int)textWidth("Room ID: ")/2, (int) (height/1.7), "Room ID: ", room_id));
    this.inputs.add(new TextInput(width/2-(int)textWidth("Player Name: ")/2, (int) (height/1.5), "Player Name: ", name));
    this.buttons.add(new Button(10, height-70, 200, 50, "Back", back));
    this.buttons.add(new Button(width/2-210, height-70, 200, 50, "Host Game", host_game));
    this.buttons.add(new Button(width/2+10, height-70, 200, 50, "Join Game", join_game));
  }

  @Override
    void draw() {
    background(60, 72, 107);
    
    textSize(60);
    text("Server Setup", width/2-textWidth("Server Setup")/2, height/5);
    
    textSize(30);
    text(errstr, width/2-textWidth(errstr)/2, height-140);
    this.renderUI();
  }
}

class RemotePlayerStageContext extends GameStageContext {
  class RpcInterface extends PlayerInteractions {
    // Just extending the standard player interactions, should be fine...
    void playerLeave(String name) {
      for (Player pl : game_state.players) {
        if (!pl.name.equals(name)) {
          continue;
        }

        pl.reset();
        if (pl.name.equals(game_state.getPlayer().name)) {
          new PlayerInteractions().endTurn();
        }

        game_state.players.remove(pl);
      }
    }
  }

  @Override
    void draw() {
    fill(45, 45, 45, 90);
    rect(0, 0, width, height);

    ArrayList<Card> current_cards = new ArrayList<Card>(game_state.current_cards);

    int x_pos = width/2-(IMG_W*3/2);
    for (Card c : current_cards) {
      c.render(x_pos, height/10, false);
      x_pos += IMG_W;
    }


    fill(240, 240, 240);
    textSize(60);
    String ai_name = game_state.getPlayer().name;
    text(ai_name + " is currently playing...", width/2-textWidth(ai_name + " is currently playing...")/2, height/2);

    if (game_state.player_client.available() > 0) {
      String json = game_state.player_client.readStringUntil(125); // }
      if (json==null) {
        return;
      }
      Object ret;

      try {
        ret = invokeJsonRPC(json, RpcInterface.class, new RpcInterface());
      }
      catch(Exception e) {
        println(e.getMessage());
        return;
      }
    }
  }
}

class PlayerListOnlineStageContext extends GameStageContext {
  boolean is_player_ready = false;
  
  class RpcInterface {
    void setPlayerList(List<String> names, List<List<Integer>> card_ids) {
      for (Player player : game_state.players) {
        player.reset();
      }

      game_state.players = new ArrayList<Player>();

      for (int i = 0; i < names.size(); i++) {
        if (names.get(i).equals(game_state.online_name)) {
          // Create normal Player Instance
          Player plr = new Player(names.get(i));

          List<Card> cards = new ArrayList<>();
          for (int id : card_ids.get(i)) {
            Card card = game_state.getCardFromID(id);
            cards.add(card);
            game_state.cards.remove(card);
          }

          plr.addToHand(cards);

          println("Created Local Player ", names.get(i));
          game_state.players.add(plr);
        } else {
          // Create Remote Player Instance
          println("Created Remote Player", names.get(i));
          game_state.players.add(new RemotePlayer(names.get(i), card_ids.get(i)));
        }
      }
    }

    void reject(String cause) {
      game_state.setGameStage(new ErrorStageContext("You were rejected from Room entry: " + cause));
    }


    void startGame(List<Integer> global_deck) {
      game_state.cards.addAll(game_state.current_cards);
      game_state.current_cards = new ArrayList<Card>();

      for ( int id : global_deck ) {
        Card card = game_state.getCardFromID(id);
        game_state.current_cards.add(card);
      }

      game_state.setTradeLock(false);
      game_state.setLastRound(false);

      game_state.player_interactor = new OnlinePlayerInteractions();

      game_state.setPlayer(game_state.players.get(0));

      Player curr_player = game_state.getPlayer();

      if (curr_player.is_remote) {
        game_state.setGameStage(new RemotePlayerStageContext());
      } else if (curr_player.is_ai) {
        game_state.setGameStage(new AiStageContext());
        thread("ai_play");
      } else {
        game_state.setGameStage(new PlayingStageContext());
      }
    }
  }

  @Override
    void initUI() {
    OnBtnClickEventListener leave = () -> {
      game_state.player_client.dispose();
      game_state.setGameStage(new MenuStageContext());
    };

    OnBtnClickEventListener ready = () -> {
      is_player_ready = true;
      rpcToServer("ready");
    };


    this.buttons.add(new Button(10, height-70, 200, 50, "Leave", leave));
    this.buttons.add(new Button(width-210, height-70, 200, 50, "Ready", ready));
  }

  @Override
    void draw() {
    background(60, 72, 107);
    this.renderUI();

    textSize(26);
    textAlign(LEFT, BOTTOM);
    text("Connected to " + game_state.server_addr + " in Room " + game_state.room_id, 10, 40);

    if (is_player_ready) {
      textSize(22);
      text("You are Ready", width-105-textWidth("You are Ready")/2, height-90);
    }

    textAlign(LEFT, CENTER);
    fill(240, 240, 240);
    textSize(37);
    int x = width/2 - 40;
    int y = 50;

    for (Player player : game_state.players) {
      text(player.name, x, y);
      y += 40;
    }

    if (game_state.player_client.available() > 0) {
      String json = game_state.player_client.readStringUntil(125); // }
      if (json==null) {
        return;
      }
      Object ret;

      try {
        ret = invokeJsonRPC(json, RpcInterface.class, new RpcInterface());
      }
      catch(Exception e) {
        println(e.getMessage());
        return;
      }
    }
  }
}

class ErrorStageContext extends GameStageContext {
  String error;

  ErrorStageContext(String error) {
    super();
    this.error = error;
  }

  @Override
    void initUI() {
    OnBtnClickEventListener go_to_menu = () -> {
      game_state.setGameStage(new MenuStageContext());
    };

    this.buttons.add(new Button(width/2-100, height-70, 200, 50, "Go to Menu", go_to_menu));
  }

  @Override
    void draw() {
    background(60, 72, 107);
    this.renderUI();
    text(error, width/2-textWidth(error)/2, height/2);
  }
}

class MenuStageContext extends GameStageContext {
  @Override
    void initUI() {
    OnBtnClickEventListener start_normal_game = () -> {
      // Prevent annoying flicker before switching due to rotating
      background(60, 72, 107);
      game_state.is_online = false;
      game_state.setGameStage(new BeginStageContext());
    };

    OnBtnClickEventListener start_online_game = () -> {
      background(60, 72, 107);
      game_state.is_online = true;
      game_state.setGameStage(new BeginOnlineStageContext());
    };

    OnBtnClickEventListener quit_game = () -> {
      background(60, 72, 107);
      fill(222);
      textSize(30);
      text("Exiting Game...", width/2-textWidth("Exiting Game...")/2, height/2);
      exit();
    };

    OnBtnClickEventListener toggle_music = () -> {
      if (audio_thread.isInterrupted() || !audio_thread.isAlive()) {
        audio_thread = new AudioThread();
        audio_thread.start();
      } else {
        audio_thread.interrupt();
      }
    };

    this.buttons.add(new Button(10, height-70, 200, 50, "Toggle Music", toggle_music));
    this.buttons.add(new Button(width/2-200, height/2, 400, 70, "Start Offline Game", start_normal_game));
    this.buttons.add(new Button(width/2-200, height/2+100, 400, 70, "Start Online Game", start_online_game));
    this.buttons.add(new Button(width/2-200, height/2+200, 400, 70, "Quit Game", quit_game));
  }

  @Override
    void draw() {
    background(60, 72, 107);
    textSize(80);
    text("Schwimmen Card Game", width/2-textWidth("Schwimmen Card Game")/2, height/10);
    textSize(30);
    text("Programmed by Paul Smöch", width/2-textWidth("Programmed by Paul Smöch")/2, height/7);

    this.renderUI();

    String music_state;


    if (audio_thread.isInterrupted() || !audio_thread.isAlive()) {
      music_state = "Music: OFF";
    } else {
      music_state = "Music: ON";
    }

    textSize(20);
    text(music_state, 105-textWidth(music_state)/2 + 10, height-75);


    rotate(PI/3.0);
    game_state.cards.get(0).render((int) width/3, height/10, false);

    rotate(-(PI/3.0));

    rotate(-(PI/8.0));
    game_state.cards.get(4).render((int) width/2, height+50, false);
    rotate((PI/8.0));
  }
}
