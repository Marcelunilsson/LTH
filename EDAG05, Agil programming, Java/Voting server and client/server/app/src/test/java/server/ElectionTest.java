package server;

import static org.junit.jupiter.api.Assertions.assertEquals;

import com.google.gson.Gson;
import java.util.ArrayList;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class ElectionTest {
  private UnadornedElection unadornedElection;
  private Election election;
  private Gson gson = new Gson();
  private final String description = "Best motion picture in 2019";
  private final String startTime = "2020-11-02 10:15:00";
  private final String finishTime = "2020-11-23 15:00:00";
  private final String administratorEmail = "administratorEmail";
  private final String electionId = "random";
  private final String voterEmail = "asdf@asdf.com";
  private final String candidateName = "movie";
  private final String voterCardId = "voter id";
  // candidateId is added just to compile
  private final String candidateId = "candidate id";
  private ArrayList<String> voterCardIdList = new ArrayList<String>();
  private final List<String> candidateIdList = new ArrayList<String>();
  private String votersString =
      "[{\"email\":\"" + voterEmail + "\",\"voterCardId\":\"" + voterCardId + "\"}]";

  private Candidate cand = new Candidate(candidateName, candidateId);

  private String candidatesString =
      "[{\"name\":\"" + candidateName + "\",\"candidateId\":\"" + candidateId + "\"}]";

  private String pluralityVotingString = "{\"votes\":{},\"totalVotes\":0}";

  Voter voter;

  // json which is used for posting (without id)
  String jsonPost =
      "{\"description\":\""
          + description
          + "\","
          + "\"startTime\":\""
          + startTime
          + "\","
          + "\"finishTime\":\""
          + finishTime
          + "\","
          + "\"administratorEmail\":\""
          + administratorEmail
          + "\","
          + "\"voters\":"
          + votersString
          + ","
          + "\"candidates\":"
          + candidatesString
          + "}";
  // json which we want to get (with id)
  String jsonGet =
      "{\"description\":\""
          + description
          + "\","
          + "\"startTime\":\""
          + startTime
          + "\","
          + "\"finishTime\":\""
          + finishTime
          + "\","
          + "\"administratorEmail\":\""
          + administratorEmail
          + "\","
          + "\"electionId\":\""
          + electionId
          + "\","
          + "\"voters\":"
          + votersString
          + ","
          + "\"candidates\":"
          + candidatesString
          + ","
          + "\"pluralityVoting\":"
          + pluralityVotingString
          + "}";

  @BeforeEach
  public void setUp() {
    unadornedElection =
        new UnadornedElection(
            description,
            startTime,
            finishTime,
            administratorEmail,
            List.of(new UnadornedVoter(voterEmail)),
            new ArrayList<UnadornedCandidate>());
    voterCardIdList.add(voterCardId);
    election = unadornedElection.withId(electionId, voterCardIdList, candidateIdList);
    voter = new Voter(voterCardId, voterEmail);
  }

  @Test
  void testAddVoter() {
    election.addVoter(voter);
    assertEquals(election.getVoters().get(1), voter);
  }

  @Test
  void testAddCandidate() {
    election.addCandidate(cand);
    assertEquals(election.getCandidates().get(0), cand);
  }

  /**
   * Tests that we can convert an Election object to json and that the json representation is
   * correct Also tests that unadeornedElection.withId(id) works!
   */
  @Test
  void testToJson() {
    election.addCandidate(cand);
    String gsonJson = gson.toJson(election);
    assertEquals(gsonJson.substring(0, 50), jsonGet.substring(0, 50)); // unnessesary test
  }

  /**
   * Test that we can convert a json representation of an Election to an Election-object and that
   * the object representation is correct
   */
  @Test
  void testFromJson() {
    election.addCandidate(cand);
    Election newElection =
        gson.fromJson(jsonPost, UnadornedElection.class)
            .withId(electionId, voterCardIdList, candidateIdList);
    // We want to see that newElection is equal to election, do this by converting both of these to
    // json-strings
    // and comparing those strings. This is based on that the test 'testToJson' works
    newElection.addCandidate(cand);

    String oldElectionJson = gson.toJson(election);
    String newElectionJson = gson.toJson(newElection);
    System.out.println(oldElectionJson);
    System.out.println(newElectionJson);
    assertEquals(oldElectionJson, newElectionJson);
  }
}
