package server;

import java.util.HashMap;
import java.util.Map;

public class PluralityVoting {

  private Map<String, String> votes = new HashMap<>();
  private int totalVotes = 0;

  public void castVote(String voterCardId, String candidateId) {
    // need to check somewhere that the candidateId is valid!
    if (!votes.containsKey(voterCardId)) {
      totalVotes++;
    }
    votes.put(voterCardId, candidateId);
  }

  // we cannot determine ties!
  public String calculateWinner() {
    Map<String, Integer> voteCount = new HashMap<>();
    String candidateWinner = "no votes in election";
    int mostVotes = 0;
    for (Map.Entry<String, String> vote : votes.entrySet()) {
      String candidateId = vote.getValue();
      int nbrVotes = 1;
      if (voteCount.containsKey(candidateId)) {
        nbrVotes = voteCount.get(candidateId) + 1;
      }
      if (nbrVotes > mostVotes) {
        candidateWinner = candidateId;
        mostVotes = nbrVotes;
      }
      voteCount.put(candidateId, nbrVotes);
    }
    return candidateWinner;
  }

  public int getTotalVotes() {
    return totalVotes;
  }
}
