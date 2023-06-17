class Player {
  String name;
  Client client;
  List<Integer> cards;
  Room room;
  boolean is_ready;

  Player(String name, Client client, List<Integer> cards, Room room) {
    this.name = name;
    this.client = client;
    this.cards = cards;
    this.room = room;
    this.is_ready = false;
  }
}

class Room {
  String room_id;
  private List<Integer> card_ids = IntStream.rangeClosed(0, 103).boxed().collect(Collectors.toList());
  private ArrayList<Player> players;
  private boolean is_game_started = false;
  private List<Integer> global_hand;


  Room(String room_id) {
    this.room_id = room_id;
    this.players = new ArrayList<Player>();
    this.global_hand = randomDeck();
  }

  void join(Client client, String client_name) {
    if (is_game_started) {
      rejectClient(client, "Game has already started, you can not join.");
      return;
    }

    for (Player player : players) {
      if (player.name.equals(client_name)) {
        rejectClient(client, "Client with this name already exsists in this Room");
        return;
      }
    }

    List<Integer> deck;
    if (card_ids.size() <= 3) {
      rejectClient(client, "Maximum Player limit Reached for this Room");
      return;
    } else {
      deck = randomDeck();
    }

    Player new_player = new Player(client_name, client, deck, this);

    players.add(new_player);
    sendPlayerlist();

    LOGGER.info("Client " + client_name + " joined!");
  }

  List<Integer> randomDeck() {
    List<Integer> deck = new ArrayList<Integer>();

    for (int i = 0; i < 3; i++) {
      int rand_idx = Math.round(random(0, card_ids.size() - 1));
      deck.add(card_ids.get(rand_idx));
      card_ids.remove(rand_idx);
    }

    return deck;
  }


  void sendPlayerlist() {
    ArrayList<List<Integer>> decks = new ArrayList<>();
    ArrayList<String> names = new ArrayList<>();

    for (Player player : players) {
      decks.add(player.cards);
      names.add(player.name);
    }

    serverBroadcast(composeRpcMessage("setPlayerList", names, decks));
  }

  void setGameStatus(boolean is_started) {
    is_game_started = is_started;
  }

  void initNewRound() {
    for ( Player pl : players ) {
      // Return Cards 
      this.card_ids.addAll(pl.cards);
      
      // Give new Cards
      pl.cards = new ArrayList<Integer>(randomDeck());
    }
    
    this.card_ids.addAll(this.global_hand);
    this.global_hand = randomDeck();
    
    sendPlayerlist();
  }

  void listen() {
    // Listen to events of room clients and do the things
    List<Player> toRemove = new ArrayList<Player>();
    
    for (Player player : players) {
      Client client = player.client;
      if (!client.active()) {
        toRemove.add(player);
        continue;
      }
      if (client.available() > 0) {
        String json = client.readStringUntil(125); // }
        if (json==null) {
          continue;
        }
        LOGGER.info(msg("New message from", client.ip()+":", json));
        Object ret;

        try {
          ret = invokeJsonRPC(json, RoomRpcInterface.class, new RoomRpcInterface(player));
          if ((boolean) ret) {
            clientBroadcast(client, json);
          }
        }
        catch(Exception e) {
          // Make this less lazy
          LOGGER.warning(msg("Failed to parse RPC", json, "of client", client.ip(), "with error:", e.getMessage()));

          continue;
        }
      }
    }

    this.removeInactive(toRemove);
  }

  private void removeInactive(List<Player> inactive) {
    inactive.forEach((Player pl) -> {
        this.players.remove(pl);
      }
    );

    if (inactive.size() > 0) {
      if (this.players.size() <= 0) {
        LOGGER.info(msg("Room", this.room_id, "removed because no players are present."));
        rooms.remove(this.room_id);
        return;
      }

      if (!is_game_started) {
        sendPlayerlist();
      } else {
        inactive.forEach((Player pl) -> {
          serverBroadcast(composeRpcMessage("playerLeave", pl.name));
        }
        );
      }
    }
  }

  boolean checkReadyStatus() {
    boolean all_ready = false;
    for ( Player pl : players ) {
      if (!pl.is_ready) {
        all_ready = false;
        break;
      } else {
        all_ready = true;
      }
    }
    
    return all_ready;
  }

  void startGame() {
    serverBroadcast(composeRpcMessage("startGame", global_hand));
    setGameStatus(true);
    
    for ( Player pl : players) {
      pl.is_ready = false;
    }
  }
  
  private void serverBroadcast(String msg) {
    LOGGER.info(msg("Broadcasting to everyone:", msg));
    for (Player player : players) {
      player.client.write(msg);
    }
  }

  private void clientBroadcast(Client client, String msg) {
    LOGGER.info(msg("Broadcasting to everyone but", client.ip(), ":", msg));
    for (Player player : players) {
      if (player.client.equals(client)) {
        continue;
      }

      player.client.write(msg);
    }
  }
}
