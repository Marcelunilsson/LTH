package server;

import static spark.Spark.*;

public class App {
  private static int PORT = 4242;

  public static void main(String[] args) {
    var server = new ElectionServer();
    port(PORT);
    get(
        "/voter-cards/:voter-card-id",
        (req, res) -> server.getVoterCard(req, res, req.params(":voter-card-id")));

    post(
        "/voter-cards/:voter-card-id/irv-votes",
        (req, res) -> server.castInstantRunoffVote(req, res, req.params(":voter-card-id")));

    post(
        "/voter-cards/:voter-card-id/plurality-votes",
        (req, res) -> server.castPluralityVote(req, res, req.params(":voter-card-id")));

    get(
        "/elections/:election-id/plurality-results",
        (req, res) -> server.getPluralityResult(req, res, req.params(":election-id")));
    get(
        "/elections/:election-id/irv-results",
        (req, res) -> server.getInstantRunoffResult(req, res, req.params(":election-id")));
    post("/elections", (req, res) -> server.postElection(req, res));
    get(
        "/elections/:election-id/voters",
        (req, res) -> server.getVoters(req, res, req.params(":election-id")));
    get(
        "/elections/:election-id/candidates",
        (req, res) -> server.getCandidates(req, res, req.params(":election-id")));

    // not to be included later, but need it to vote with postman
    get(
        "/elections/:election-id",
        (req, res) -> server.getElection(req, res, req.params(":election-id")));
  }
}
