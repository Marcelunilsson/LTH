package client;

import java.util.List;

public class ElectionInfo {
  String description;
  String startTime;
  String endTime;
  List<Candidate> candidates; // if we got problems => maybe change to a vector
}
