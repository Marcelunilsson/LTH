package client;

import com.google.gson.Gson;
import java.io.IOException;
import java.io.PrintStream;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

abstract class Commands {

  private String description;

  public Commands(String description) {
    this.description = description;
  }

  public String description() {
    return description;
  }

  public abstract void execute(Scanner input, PrintStream output);
}

// Comment this
class ExitCommand extends Commands {

  public ExitCommand() {
    super("exit program");
  }

  @Override
  public void execute(Scanner input, PrintStream output) {
    output.println("Thank you!");
    System.exit(0);
  }
}

// Comment this
class HelpCommand extends Commands {

  public HelpCommand() {
    super("");
  }

  @Override
  public void execute(Scanner input, PrintStream output) {
    output.println("");
    output.println("Nope, that's not one of the available commands");
    output.println("-- please read carefully, and try again.");
    output.println("");
  }
}

// Comment this
class VoteCommand extends Commands {

  public VoteCommand() {
    super("vote for candidates");
  }

  @Override
  public void execute(Scanner input, PrintStream output) {
    try {
      // Checks with server if the voter-id supplied is valid --> Returns
      output.print("Enter your voter-card-id: ");
      var voterId = input.nextLine().strip();
      var serverUrl = App.baseUrl + URLEncoder.encode(voterId, "UTF-8");
      var client = HttpClient.newHttpClient();
      var request = HttpRequest.newBuilder().uri(URI.create(serverUrl)).GET().build();
      var response = client.send(request, HttpResponse.BodyHandlers.ofString());

      if (response.statusCode() == 200) {
        var body = response.body();
        var gson = new Gson();

        var electionInfo = gson.fromJson(body, ElectionInfo.class);

        output.println(electionInfo.description);
        var count = 1;
        for (var candidate : electionInfo.candidates) {
          output.printf("%d . %s \n", count, candidate.name);
          count++;
        }
        output.println();
        output.println("Order the candidates you want to vote for:");
        Scanner scan = new Scanner(input.nextLine().strip());
        List<String> candidateIds = new ArrayList<String>();
        while (scan.hasNextInt()) {
          candidateIds.add(electionInfo.candidates.get(scan.nextInt() - 1).candidateId);
        }
        String irvBallotJson = gson.toJson(new InstantRunoffBallot(voterId, candidateIds));

        // CREATING URL TO SEND VOTE TO SERVER
        var urlVote = App.baseUrl + URLEncoder.encode(voterId, "UTF-8") + "/irv-votes";
        // output.println(urlVote);
        var requestVote =
            HttpRequest.newBuilder()
                .uri(URI.create(urlVote))
                .POST(HttpRequest.BodyPublishers.ofString(irvBallotJson))
                .build();
        var responseVote = client.send(requestVote, HttpResponse.BodyHandlers.ofString());

        if (responseVote.statusCode() == 201) {
          output.println("Your vote has been cast.");
          output.println();
        } else {
          output.println(responseVote.statusCode());
        }
      } else {
        output.println("VoterCardId does not exist.");
        output.println(response.body());
      }
    } catch (InterruptedException e) {
      output.println(e.toString());
    } catch (IOException e) {
      output.println(e.toString());
    }
  }
}
