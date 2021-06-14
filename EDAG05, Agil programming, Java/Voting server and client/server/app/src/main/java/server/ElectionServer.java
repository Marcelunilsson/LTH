package server;

import com.google.gson.Gson;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import spark.Request;
import spark.Response;

public class ElectionServer {

  private IdGenerator idGen = new IdGenerator();
  private Gson gson = new Gson();
  private Map<String, Election> electionsMap = new HashMap<>();
  private Map<String, Election> voterCardToElectionMap = new HashMap<>();
  private final String ELECTION_NOT_FOUND = "Could not find election with the given election-id";
  private final String VOTERCARD_NOT_FOUND = "Could not find election from the given voter card id";

  public String getVoterCard(Request req, Response res, String voterCardId) {
    if (voterCardExists(voterCardId)) {
      res.status(200);
      Election election = voterCardToElectionMap.get(voterCardId);
      VoterCard voterCard =
          new VoterCard(
              election.startTime,
              election.finishTime,
              election.description,
              election.getCandidates());
      return gson.toJson(voterCard);
    } else {
      res.status(404);
      return VOTERCARD_NOT_FOUND;
    }
  }

  public String getCandidates(Request req, Response res, String electionId) {
    if (electionExists(electionId)) {
      var election = electionsMap.get(electionId);
      res.status(200);
      String out = "{\n" + "   \"candidates\": " + gson.toJson(election.getCandidates()) + "\n}";
      return out;
    }
    res.status(404);
    return ELECTION_NOT_FOUND;
  }

  public String getElection(Request req, Response res, String electionId) {
    if (electionExists(electionId)) {
      res.status(200);
      return gson.toJson(electionsMap.get(electionId));
    }
    res.status(404);
    return ELECTION_NOT_FOUND;
  }

  public String postElection(Request req, Response res) {
    var body = req.body();
    var unadornedElection = gson.fromJson(body, UnadornedElection.class);
    var eId = idGen.uuid();
    List<String> voterCardIds = unadornedElection.voterCardIds(idGen);
    List<String> candidateIds = unadornedElection.candidateIds(idGen);
    var election = unadornedElection.withId(eId, voterCardIds, candidateIds);
    for (String voterCardId : voterCardIds) {
      voterCardToElectionMap.put(voterCardId, election);
    }
    electionsMap.put(eId, election);
    res.status(201);
    return "Location: /elections/" + eId;
  }

  public String getVoters(Request req, Response res, String electionId) {
    if (electionExists(electionId)) {
      var election = electionsMap.get(electionId);
      String out = "{\n" + "   \"voters\": " + gson.toJson(election.getVoters()) + "\n}";
      return out;
    }
    res.status(404);
    return ELECTION_NOT_FOUND;
  }

  public String castPluralityVote(Request req, Response res, String voterCardId) {
    if (voterCardExists(voterCardId)) {
      String body = req.body();
      Election election = voterCardToElectionMap.get(voterCardId);
      var pluralityBallot = gson.fromJson(body, PluralityBallot.class);
      String candidateId = pluralityBallot.getCandidateId();
      election.castPluralityVote(voterCardId, candidateId);
      return "Vote casted";
    }
    res.status(404);
    return VOTERCARD_NOT_FOUND;
  }

  public String getPluralityResult(Request req, Response res, String electionId) {
    if (electionExists(electionId)) {
      res.status(200);
      ElectionWinner winner = electionsMap.get(electionId).getPluralityWinner();
      return gson.toJson(winner);
    }
    res.status(404);
    return ELECTION_NOT_FOUND;
  }

  public String castInstantRunoffVote(Request req, Response res, String voterCardId) {
    if (voterCardExists(voterCardId)) {
      String body = req.body();
      Election election = voterCardToElectionMap.get(voterCardId);
      var irvBallot = gson.fromJson(body, InstantRunoffBallot.class);
      List<String> ordering = irvBallot.candidateIds;
      election.castInstantRunoffVote(voterCardId, ordering);
      res.status(201);
      return "Vote casted";
    }
    res.status(404);
    return VOTERCARD_NOT_FOUND;
  }

  public String getInstantRunoffResult(Request req, Response res, String electionId) {
    if (electionExists(electionId)) {
      res.status(200);
      ElectionWinner winner = electionsMap.get(electionId).getInstantRunoffWinner();
      return gson.toJson(winner);
    }
    res.status(404);
    return ELECTION_NOT_FOUND;
  }

  private boolean voterCardExists(String voterCardId) {
    return voterCardToElectionMap.containsKey(voterCardId);
  }

  private boolean electionExists(String electionId) {
    return electionsMap.containsKey(electionId);
  }
}
