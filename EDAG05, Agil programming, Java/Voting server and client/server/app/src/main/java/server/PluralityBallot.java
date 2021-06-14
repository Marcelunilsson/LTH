package server;

public class PluralityBallot {
  final String candidateId;

  public PluralityBallot(String candidateId) {
    this.candidateId = candidateId;
  }

  public String getCandidateId() {
    return candidateId;
  }
}
