/*
 * Server for card_game using JSON RPC
 */

import processing.net.*;
import java.util.logging.Logger;
import java.util.logging.Level;
import java.util.Collection;
import java.util.List;
import java.lang.reflect.Method;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Array;
import java.util.Arrays;
import java.util.Map;
import java.util.Iterator;
import java.util.Map.Entry;
import java.util.Set;
import java.util.stream.IntStream;
import java.util.stream.Collectors;

int SERVER_PORT = 6969;
String SERVER_HOST = "0.0.0.0";

Server server;
HashMap<String, Room> rooms;
ArrayList<Client> global_clients;

final static Logger LOGGER = Logger.getLogger("CardGameServer");


void setup() {
  surface.setVisible(false);
  global_clients = new ArrayList<Client>();
  rooms = new HashMap<String, Room>();
  LOGGER.setLevel(Level.ALL);

  String portEnv = System.getenv("SCHWIMMEN_PORT");
  if (portEnv != null) {
    try {
      SERVER_PORT = Integer.parseInt(portEnv);
      LOGGER.info(msg("Using custom Port:", portEnv));
    } catch (NumberFormatException e) {
    }
  }
  
  String hostEnv = System.getenv("SCHWIMMEN_HOST");
  if (hostEnv != null) {
    SERVER_HOST = hostEnv;
    LOGGER.info(msg("Using custom Host:", hostEnv));
  }
  
  server = new Server(this, SERVER_PORT, SERVER_HOST);
  LOGGER.info(msg("Started Server with host", SERVER_HOST, "on Port", SERVER_PORT));
}


void draw() {
  ArrayList<Client> clients_to_listen = new ArrayList<Client>(global_clients);
  for(Client client : clients_to_listen) {
    if (client.available() > 0) {
      String json = client.readStringUntil(125);
      if (json==null) {
        continue;
      }
      LOGGER.info(msg("New message from", client.ip()+":", json));
      Object ret;
      
      try {
        ret = invokeJsonRPC(json, OpenRpcInterface.class, new OpenRpcInterface(client));
      } catch(RpcParseException e) {
        LOGGER.warning(msg("Failed to parse RPC", json, "of client", client.ip(), "with error:", e.getMessage()));
        continue;
      }
    }
  }
  for(Room room : rooms.values()) { 
    room.listen();
  }
}

void serverEvent(Server someServer, Client client) {
  LOGGER.info("New Client: " + client.ip());
  global_clients.add(client);
}

void disconnectEvent(Client client) {
  LOGGER.info("Client Disconnected: " + client.ip());
}
