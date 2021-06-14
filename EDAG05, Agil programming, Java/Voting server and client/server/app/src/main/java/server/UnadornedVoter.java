package server;

public class UnadornedVoter {
  public String email;

  public UnadornedVoter(String email) {
    this.email = email;
  }

  public Voter withId(String voterCardId) {
    return new Voter(voterCardId, email);
  }
}
