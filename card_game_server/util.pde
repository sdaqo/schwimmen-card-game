String composeRpcMessage(String method_name, Object... params) {
     ObjectMapper mapper = new ObjectMapper();
     RpcMessage msg = new RpcMessage();
     msg.method = method_name;
     msg.params = params;
      
     try {
       return mapper.writeValueAsString(msg);
     } catch(JsonProcessingException e) {
       LOGGER.warning(msg("Failed to parse into JSON"));
       return null;
     }
}


String msg(Object... parts) {
  String ret = "";
  for(Object obj : parts) {
    ret += obj.toString() + " ";
  }
  return ret;
}


void rejectClient(Client client, String cause) {
  String rpc_msg = composeRpcMessage("reject", cause);
  client.write(rpc_msg);
}
