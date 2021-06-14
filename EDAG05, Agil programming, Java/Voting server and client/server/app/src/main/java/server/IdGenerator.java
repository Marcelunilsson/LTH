package server;

class IdGenerator {

  public String uuid() {
    return java.util.UUID.randomUUID().toString();
  }
}
