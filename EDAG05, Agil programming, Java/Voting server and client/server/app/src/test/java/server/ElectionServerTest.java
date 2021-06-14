package server;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import java.util.List;
import org.junit.jupiter.api.Test;
import spark.Request;
import spark.Response;

public class ElectionServerTest {

  private final Gson gson = new Gson();
  private final ElectionServer server = new ElectionServer();

  @Test
  void test() {
    var electionNames = List.of("e1", "e2", "e3", "e4", "e5");
    String electionId = postElection(electionNames.get(0));
    getElection(electionNames.get(0), electionId);
    getNonExistingElection();
  }

  String postElection(String electionName) {
    var req = mock(Request.class);
    var res = mock(Response.class);
    when(req.body()).thenReturn(formatJson(electionName));
    var location = server.postElection(req, res);
    verify(res).status(201);
    return location.replace("Location: /elections/", "");
  }

  void getElection(String description, String electionId) {
    var req = mock(Request.class);
    var res = mock(Response.class);
    String found = server.getElection(req, res, electionId);
    verify(res).status(200);
    assertEquals(jsonWithId(description, electionId).substring(0, 30), found.substring(0, 30));
  }

  void getNonExistingElection() {
    var req = mock(Request.class);
    var res = mock(Response.class);
    String notFound = server.getElection(req, res, "inte ett electionId");
    verify(res).status(404);
  }

  Election parseElection(String json) {
    return gson.fromJson(json, Election.class);
  }

  List<Election> parseElections(String json) {
    var electionList = new TypeToken<List<Election>>() {}.getType();
    return gson.fromJson(json, electionList);
  }

  String formatJson(String electionName) {
    return String.format(
        "{\"description\":\"%s\","
            + "\"startTime\":\"2020-11-02 10:15:00\","
            + "\"finishTime\":\"2020-11-23 15:00:00\","
            + "\"administratorEmail\":\"administratorEmail\","
            + "\"voters\":[],"
            + "\"candidates\":[{\"name\":\"movie\"}]}",
        electionName);
  }

  String jsonWithId(String description, String electionId) {
    return String.format(
        "{\"description\":\"%1$s\","
            + "\"startTime\":\"2020-11-02 10:15:00\","
            + "\"finishTime\":\"2020-11-23 15:00:00\","
            + "\"administratorEmail\":\"administratorEmail\","
            + "\"electionId\":\"%2$s\","
            + "\"voters\":[],"
            + "\"candidates\":[]}",
        description, electionId);
  }

  Candidate makeCandidate(String candidateName, String candidateId) {
    var unadornedCandidate = new UnadornedCandidate(candidateName);
    return unadornedCandidate.withId(candidateId);
  }
}
