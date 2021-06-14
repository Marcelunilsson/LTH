package server;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class IRVTest {
  private InstantRunoffVoting testIRV;

  // Creating candidateIds
  private final String candidate1Id = "candidate1 id";
  private final String candidate2Id = "candidate2 id";
  private final String candidate3Id = "candidate3 id";

  // Create voters

  private final String voterCardId1 = "voter id 1";
  private final String voterCardId2 = "voter id 2";
  private final String voterCardId3 = "voter id 3";
  private final String voterCardId4 = "voter id 4";
  private final String voterCardId5 = "voter id 5";

  List<String> votedCandidateIds1 = List.of(candidate1Id, candidate2Id);
  List<String> votedCandidateIds2 = List.of(candidate2Id, candidate1Id);
  List<String> votedCandidateIds3 = List.of(candidate3Id, candidate2Id, candidate1Id);
  List<String> votedCandidateIds4 = List.of(candidate1Id, candidate3Id, candidate2Id);
  List<String> votedCandidateIds5 = List.of(candidate3Id, candidate2Id, candidate1Id);

  // --------------------------------------------------------------------------------------------------------

  @BeforeEach
  public void setUp() {
    testIRV = new InstantRunoffVoting();
  }

  @Test
  void testIRVEmpty() {
    assertEquals("No votes have been cast.", testIRV.calculateWinner());
  }

  @Test
  void testIRVOneVoteCast() {
    testIRV.castVote(voterCardId1, votedCandidateIds1);
    assertEquals(1, testIRV.getTotalVotes());
    assertEquals(candidate1Id, testIRV.calculateWinner());
  }

  @Test
  void testIRVFiveVotesCast() {
    testIRV.castVote(voterCardId1, votedCandidateIds1);
    testIRV.castVote(voterCardId2, votedCandidateIds2);
    testIRV.castVote(voterCardId3, votedCandidateIds3);
    testIRV.castVote(voterCardId4, votedCandidateIds4);
    testIRV.castVote(voterCardId5, votedCandidateIds5);
    assertEquals(5, testIRV.getTotalVotes());
    assertEquals(candidate1Id, testIRV.calculateWinner());
  }

  @Test
  void testIRVTieConsistency() {
    testIRV.castVote(voterCardId1, votedCandidateIds1);
    testIRV.castVote(voterCardId2, votedCandidateIds2);
    assertEquals(2, testIRV.getTotalVotes());
    for (int i = 0; i < 10; i++) {
      assertEquals(candidate2Id, testIRV.calculateWinner());
    }
  }
}
