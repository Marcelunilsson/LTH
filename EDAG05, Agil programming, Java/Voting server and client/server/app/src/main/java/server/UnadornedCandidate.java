package server;

public class UnadornedCandidate {

  final String name;

  UnadornedCandidate(String name) {
    this.name = name;
  }

  Candidate withId(String candidateId) {
    return new Candidate(name, candidateId);
  }
}
