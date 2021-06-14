package client;

import java.util.List;

public class InstantRunoffBallot {
  final String voterCardId;
  final List<String> candidateIds;

  public InstantRunoffBallot(String voterCardId, List<String> candidateIds) {
    this.voterCardId = voterCardId;
    this.candidateIds = candidateIds;
  }
}
