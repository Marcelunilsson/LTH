package server;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

public class UnadornedElection {
  private final String description;
  private final String startTime;
  private final String finishTime;
  private final String administratorEmail;
  private final List<UnadornedVoter> voters;
  private final List<UnadornedCandidate> candidates;

  /**
   * Stringly typed contructor, but UnadornedElection is only created with gson, which makes it ok
   */
  public UnadornedElection(
      String description,
      String startTime,
      String finishTime,
      String administratorEmail,
      List<UnadornedVoter> voters,
      List<UnadornedCandidate> candidates) {
    this.description = description;
    this.startTime = startTime;
    this.finishTime = finishTime;
    this.administratorEmail = administratorEmail;
    this.voters = voters;
    this.candidates = candidates;
  }

  public Election withId(
      String electionId, List<String> voterCardIdList, List<String> candidateIdList) {
    // assume that voterCardIdList and voters are of same length
    ArrayList<Voter> voterList = new ArrayList<>();
    ArrayList<Candidate> candidateList = new ArrayList<>();
    for (int i = 0; i < voterCardIdList.size(); i++) {
      String voterCardId = voterCardIdList.get(i);
      voterList.add(voters.get(i).withId(voterCardId));
    }
    for (int i = 0; i < candidateIdList.size(); i++) {
      String candidateID = candidateIdList.get(i);
      candidateList.add(candidates.get(i).withId(candidateID));
    }
    return new Election(
        description,
        startTime,
        finishTime,
        administratorEmail,
        electionId,
        voterList,
        candidateList);
  }

  public List<String> voterCardIds(IdGenerator idGen) {
    return voters.stream().map(unadornedVoter -> idGen.uuid()).collect(Collectors.toList());
  }

  public List<String> candidateIds(IdGenerator idGen) {
    return candidates.stream().map(unadornedCandidate -> idGen.uuid()).collect(Collectors.toList());
  }
}
