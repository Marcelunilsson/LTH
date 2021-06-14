package server;

import java.util.*;

public class Election {
  final String description;
  final String startTime;
  final String finishTime;
  private String administratorEmail;
  private String electionId;
  private List<Voter> voters;
  private List<Candidate> candidates;
  private PluralityVoting pluralityVoting;
  private InstantRunoffVoting irvVoting;

  public Election(
      String description,
      String startTime,
      String finishTime,
      String administratorEmail,
      String electionId,
      List<Voter> voters,
      List<Candidate> candidates) {
    this.electionId = electionId;
    this.description = description;
    this.startTime = startTime;
    this.finishTime = finishTime;
    this.administratorEmail = administratorEmail;
    this.voters = voters;
    this.candidates = candidates;
    pluralityVoting = new PluralityVoting();
    irvVoting = new InstantRunoffVoting();
  }

  public void addVoter(Voter v) {
    voters.add(v);
  }

  public void addCandidate(Candidate c) {
    candidates.add(c);
  }

  public List<Voter> getVoters() {
    return voters;
  }

  public List<Candidate> getCandidates() {
    return candidates;
  }

  public String getDescription() {
    return description;
  }

  public void castPluralityVote(String voterCardId, String candidateId) {
    pluralityVoting.castVote(voterCardId, candidateId);
  }

  public ElectionWinner getPluralityWinner() {
    String candidateId = pluralityVoting.calculateWinner();
    if (candidateId.equals("no votes in election")) {
      return new ElectionWinner(new Candidate("no votes", "none"), 0);
    }
    for (Candidate c : candidates) {
      if (c.candidateId.equals(candidateId)) {
        return new ElectionWinner(c, pluralityVoting.getTotalVotes());
      }
    }
    return new ElectionWinner(new Candidate("weird error", "none"), 0);
  }

  public String getStartTime() {
    return startTime;
  }

  public String getFinishTime() {
    return finishTime;
  }

  public void castInstantRunoffVote(String voterCardId, List<String> candidateIds) {
    irvVoting.castVote(voterCardId, candidateIds);
  }

  public ElectionWinner getInstantRunoffWinner() {
    String candidateId = irvVoting.calculateWinner();
    if (candidateId.equals("no winner")) {
      return new ElectionWinner(new Candidate("no votes", "none"), 0);
    }
    for (Candidate c : candidates) {
      if (c.candidateId.equals(candidateId)) {
        return new ElectionWinner(c, irvVoting.getTotalVotes());
      }
    }
    return new ElectionWinner(new Candidate("weird error", "none"), 0);
  }
}
