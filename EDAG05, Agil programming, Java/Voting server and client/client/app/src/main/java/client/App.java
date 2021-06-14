package client;

import java.io.PrintStream;
import java.util.*;

public class App {

  public static void main(String[] args) {
    baseUrl = "http://" + args[0] + "/voter-cards/";
    App clientApp = new App();
    clientApp.run();
  }

  private Scanner input;
  private PrintStream output;
  private Map<String, Commands> commands = new HashMap<>();
  private Commands helpCommand = new HelpCommand();
  public static String baseUrl;

  private void run() {
    commands.put("vote", new VoteCommand());
    commands.put("exit", new ExitCommand());
    input = new Scanner(System.in);
    output = System.out;
    while (true) {
      nextCommand().execute(input, output);
    }
  }

  private Commands nextCommand() {
    output.println("These are your alternatives:");
    commands.forEach((key, cmd) -> output.printf("%10s: %s\n", key, cmd.description()));
    output.print("What do you want to do: ");
    return commands.getOrDefault(input.nextLine().strip().toLowerCase(), helpCommand);
  }
}
