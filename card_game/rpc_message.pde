class RpcParseException extends Exception { //<>// //<>// //<>//
  RpcParseException(String message) {
    super(message);
  }
}

@JsonIgnoreProperties(ignoreUnknown = true)
  public static class RpcMessage {
  public String method;
  public Object[] params;
}

Object invokeJsonRPC(String raw_message, Class<?> rpc_interface, Object rpc_interface_instance) throws RpcParseException {
  ObjectMapper mapper = new ObjectMapper();
  RpcMessage msg;

  // Parse JSON
  try {
    msg = mapper.readValue(raw_message, RpcMessage.class);
  }
  catch(JsonProcessingException e) {
    throw new RpcParseException("Could not parse JSON");
  }

  // Search Method in the Rpc Interface
  Method method = null;
  Method[] interface_methods = rpc_interface.getMethods();

  for (Method m : interface_methods) {
    if (m.getName().equals(msg.method)) {
      method = m;
    } 
  }

  if (method == null) {
    throw new RpcParseException("Method " + msg.method + " not defined!");
  }
  
  // Invoke Method
  try {
    return method.invoke(rpc_interface_instance, msg.params);
  }
  catch(IllegalAccessException e) {
    throw new RuntimeException(
      "Could not invoke method: " + method.getName() + " with params " + Arrays.toString(msg.params)
      );
  }
  catch(InvocationTargetException e) {
    e.printStackTrace();
    throw new RuntimeException(
      "Could not invoke method: " + method.getName() + " with params " + Arrays.toString(msg.params) + ":" + e.getMessage()
      );
  }
}

void rpcToServer(String method_name, Object... params) {
    println("Calling method ", method_name, "with params", Arrays.toString(params));
    ObjectMapper mapper = new ObjectMapper();
    
    RpcMessage msg = new RpcMessage();
    msg.method = method_name;
    msg.params = params;
    
    try {
      game_state.player_client.write(mapper.writeValueAsString(msg));
    } catch (JsonProcessingException e) {
      // Ignore
    }
}
