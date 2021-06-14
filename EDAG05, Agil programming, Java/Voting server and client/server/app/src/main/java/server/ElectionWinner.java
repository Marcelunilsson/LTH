package server;

public class ElectionWinner {
  Candidate winner;
  int totalVotes;

  public ElectionWinner(Candidate winner, int totalVotes) {
    this.winner = winner;
    this.totalVotes = totalVotes;
  }
}
