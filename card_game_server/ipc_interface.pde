class OpenRpcInterface {
  Client client;

  OpenRpcInterface(Client client) {
    this.client = client;
  }

  void createRoom(String room_id) {
    if (rooms.containsKey(room_id)) {
      LOGGER.info(msg("Tried to create Room", room_id, ", but it already exsists"));
      return;
    }
    rooms.put(room_id, new Room(room_id));
    LOGGER.info(msg("Room", room_id, "created!"));
  }

  void joinRoom(String room_id, String client_name) {
    Room room = rooms.get(room_id);
    if (room == null) {
      LOGGER.info(msg("Client", client.ip(), "tried joining non-exsisting room:", room_id));
      rejectClient(this.client, msg("Room", room_id, "does not exsist"));
      return;
    }

    room.join(this.client, client_name);
    global_clients.remove(this.client);
    LOGGER.info(msg("Client", client.ip(), "joined room", room_id, "with name:", client_name));
  }
}
 
class RoomRpcInterface {
  // The boolean return value indicates wether the Rpc should be relayed to the other clients
  
  Player player;

  RoomRpcInterface(Player player) {
    this.player = player;
  }

  boolean tradeCard(Integer id1, Integer id2) {
    return true;
  }

  boolean tradeAllCards() {
    return true;
  }

  boolean closeUp() {
    return true;
  }

  boolean endTurn() {
    return true;
  }

  boolean endGame() {
    this.player.room.setGameStatus(false);
    
    return false;
  }
  
  boolean ready() {
    this.player.is_ready = true;
        
    if (this.player.room.checkReadyStatus()) {
      this.player.room.startGame();
    }
    
    return false;
  }
  
  boolean nextRound() {
    this.player.is_ready = true;
    
    if (this.player.room.checkReadyStatus()) {
      this.player.room.initNewRound();
      this.player.room.startGame();
    }
    
    return false;
  }
}
