package server;

import java.util.List;

public class VoterCard {
  public String description;
  public String startTime;
  public String finishTime;
  public List<Candidate> candidates;

  public VoterCard(
      String description, String startTime, String finishTime, List<Candidate> candidates) {
    this.description = description;
    this.startTime = startTime;
    this.finishTime = finishTime;
    this.candidates = candidates;
  }
}
