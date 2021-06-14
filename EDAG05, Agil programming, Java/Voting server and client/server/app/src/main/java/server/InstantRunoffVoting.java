package server;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;
import java.util.stream.Collectors;

public class InstantRunoffVoting {
  private Map<String, List<String>> votes = new HashMap<>();
  private int totalVotes = 0;
  private Set<String> candidates = new HashSet<>();

  public void castVote(String voterCardId, List<String> candidateIds) {
    // need to check somewhere that the candidateId is valid!
    if (!votes.containsKey(voterCardId)) {
      totalVotes++;
    }
    votes.put(voterCardId, candidateIds);
    for (String id : candidateIds) {
      candidates.add(id);
    }
  }

  public int getTotalVotes() {
    return totalVotes;
  }

  // cannot handle draws between rounds or in total election!!
  public String calculateWinner() {
    List<Map.Entry<String, Integer>> voteCount;
    boolean majorityExists = false;
    Set<String> eligibleCandidates = new HashSet<String>(candidates);
    String roundWinnerId = "No votes have been cast.";

    while (!majorityExists && eligibleCandidates.size() > 0) {

      // sort voteCount in desc order
      voteCount =
          countVotes(eligibleCandidates).stream()
              .sorted(Entry.<String, Integer>comparingByValue().reversed())
              .collect(Collectors.toList());

      // get nbrOf Votes cast in last round
      int nbrVotesLastRound =
          voteCount.stream()
              .map(entry -> entry.getValue())
              .collect(Collectors.summingInt(Integer::intValue));

      // check if round winner can create majority
      roundWinnerId = voteCount.get(0).getKey();
      int roundWinnerVotes = voteCount.get(0).getValue();

      majorityExists = roundWinnerVotes > nbrVotesLastRound / 2;

      // remove roundLoser from eligibleCandidates
      String roundLoserId = voteCount.get(voteCount.size() - 1).getKey();
      eligibleCandidates.remove(roundLoserId);
    }

    return roundWinnerId;
  }

  private List<Map.Entry<String, Integer>> countVotes(Set<String> eligibleCandidates) {
    Map<String, Integer> voteCount = new HashMap<>();
    var allVotes = votes.entrySet();
    for (var vote : allVotes) {
      var candidateList = vote.getValue();
      for (String candidateId : candidateList) {
        if (eligibleCandidates.contains(candidateId)) {
          addVote(voteCount, candidateId);
          break; // dont want one person to be able to vote on two candidates, so break!
        }
      }
    }
    return new ArrayList<>(voteCount.entrySet());
  }

  private void addVote(Map<String, Integer> voteCount, String candidateId) {
    int nbrVotes = 0;
    if (voteCount.containsKey(candidateId)) {
      nbrVotes = voteCount.get(candidateId);
    }
    voteCount.put(candidateId, nbrVotes + 1);
  }
}
