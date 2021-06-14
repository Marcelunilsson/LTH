package client;

class Candidate {

  final String candidateId;
  final String name;

  Candidate(String candidateId, String name) {
    this.candidateId = candidateId;
    this.name = name;
  }

  public String toString() {
    return String.format(
        """
                candidateId: %s
                candidateName: %s
                """,
        candidateId, name);
  }
}
