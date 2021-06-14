package server;

public class Voter {
  private String email;
  private String voterCardId;

  public Voter(String voterCardId, String email) {
    this.email = email;
    this.voterCardId = voterCardId;
  }
}
