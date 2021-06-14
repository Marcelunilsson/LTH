package server;

public class Candidate {

  final String name;
  final String candidateId;

  public Candidate(String name, String candidateId) {
    this.name = name;
    this.candidateId = candidateId;
  }

  public String getName() {
    return name;
  }
}
