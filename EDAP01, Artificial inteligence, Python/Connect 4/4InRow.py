import gym
import random
import requests
import numpy as np
from gym_connect_four import ConnectFourEnv

from timeit import default_timer as ti


env: ConnectFourEnv = gym.make("ConnectFour-v0")
# SERVER_ADRESS = "http://localhost:8000/"
SERVER_ADRESS = "https://vilde.cs.lth.se/edap01-4inarow/"
#SERVER_ADRESS = "http://lavender.blossom.dsek.se:3030/rooms/all_your_base_are_belong_to_us/"
API_KEY = 'nyckel'
STIL_ID = ["tfy11mur"]  # TODO: fill this list with your stil-id's


def MakeFourDict(nRows, nCols):
   """
   Make a dict of the possible four in a rows for the specific coordinate
   """
   rows = [[(row, col + i) for i in range(4)] for row in range(nRows) for col in range(nCols) if col +4 <= nCols]
   cols = [[(row + i, col) for i in range(4)] for row in range(nRows) for col in range(nCols) if row +4 <= nRows]
   rDiag = [[(row + i, col +i) for i in range(4)] for row in range(nRows) for col in range(nCols) if (row + 4 <= nRows and col + 4 <= nCols)]
   lDiag = [[(row + i, col -i) for i in range(4)] for row in range(nRows) for col in range(nCols) if (row + 4 <= nRows and col - 4 >= 0)]
   fourList = rows + cols + rDiag + lDiag
   
   coordList = [(row, col) for row in range(nRows) for col in range(nCols)]
   fourDict = {coord:[fl for fl in fourList if coord in fl] for coord in coordList}
   return fourDict, fourList

coordDict, fourList = MakeFourDict(6, 7)


def AvaliableMoves(boardState):
   """
   Returns a list of tuples with all the available moves
   """
   return  [(np.count_nonzero(boardState[:, col] == 0) -1, col) for col in list(np.where(boardState[0] == 0))[0]]


def PartVal(four):
   """
   Gives a value based on how close to 4 in a row your moves takes you
   or how much in the way of your opponent getting 4 in a row the move is
   """
   oppon, stud = four.count(-1), four.count(1)
   if stud == 2:
      return 40
   elif oppon == 2:
      return -20
   elif oppon == 3:
      return -200
   elif stud == 3:
      return 400
   elif stud ==4:
      return 2000
   elif oppon == 4:
      return -1000
   else: return 0
   
   
   
def StateVal(boardState):
   """
   Counts the total value from all the possible four in a row paths from one move
   dividing the points by how many possible four in a rows the move has
   """
   fourCordList = fourList
   val = sum([PartVal(four) for four in [[boardState[coord] for coord in fourCoords] for fourCoords in fourCordList]]) / len(fourCordList)
   return val


def MakeMove(board, player, move):
   """
   updates the boardstate when player makes a move
   """
   newBoard = board.copy()
   np.put(newBoard[move[0], :], move[1], player)
   return newBoard


def MiniMax(boardState, depth, alpha, beta, player):
   if depth == 0: 
      return StateVal(boardState)
   avMove = AvaliableMoves(boardState)
   if len(avMove) == 0: return .5
   savedBoard = boardState.copy()
   if player == 1:
      maxRew = -100
      for move in avMove:
         boardState = savedBoard
         rew = MiniMax(MakeMove(boardState, -1, move), depth-1, alpha, beta, -1)
         maxRew, alpha = max(maxRew, rew), max(alpha, rew)
         if beta <= alpha: break
      return maxRew
   else:
      minRew = 100
      for move in avMove:
         boardState = savedBoard
         rew = MiniMax(MakeMove(boardState, -1, move), depth-1, alpha, beta, 1)
         minRew, beta = min(minRew, rew), min(beta, rew)
         if beta <= alpha: break
      return minRew
         
         
         


def call_server(move):
   res = requests.post(SERVER_ADRESS + "move",
                       data={
                           "stil_id": STIL_ID,
                           "move": move,  # -1 signals the system to start a new game. any running game is counted as a loss
                           "api_key": API_KEY,
                       })
   # For safety some respose checking is done here
   if res.status_code != 200:
      print("Server gave a bad response, error code={}".format(res.status_code))
      exit()
   if not res.json()['status']:
      print("Server returned a bad status. Return message: ")
      print(res.json()['msg'])
      exit()
   return res


"""
You can make your code work against this simple random agent
before playing against the server.
It returns a move 0-6 or -1 if it could not make a move.
To check your code for better performance, change this code to
use your own algorithm for selecting actions too
"""


def opponents_move(boardState, env):
   env.change_player()  # change to oppoent
   avmoves = env.available_moves()
   if not avmoves:
      env.change_player()  # change back to student before returning
      return -1

   # TODO: Optional? change this to select actions with your policy too
   # that way you get way more interesting games, and you can see if starting
   # is enough to guarrantee a win
   action = random.choice(list(avmoves))
   action = student_move(boardState)

   state, reward, done, _ = env.step(action)
   if done:
      if reward == 1:  # reward is always in current players view
         reward = -1
   env.change_player()  # change back to student before returning
   return state, reward, done


def student_move(boardState):
   """
   TODO: Implement your min-max alpha-beta pruning algorithm here.
   Give it whatever input arguments you think are necessary
   (and change where it is called).
   The function should return a move from 0-6
   """
   t1 = ti()
   avMoves = AvaliableMoves(boardState)
   savedState = boardState
   bestMove = avMoves[0][1]
   maxRew = -100
   for move in avMoves:
      boardState = savedState
      boardState = MakeMove(boardState, 1, move)
      rew = MiniMax(boardState, depth = 3, alpha = -100, beta = 100, player = -1)
      if rew > maxRew: 
         bestMove = move[1]
      maxRew = max(maxRew, rew)
      boardState = savedState 
   #print(f"Best move: {bestMove} \nReward: {maxRew} \nAvailable moves: {avMoves}")
   #print(f"Time to think: {ti()-t1} seconds")
   return bestMove

      



   
          
def play_game(vs_server = False):
   """
   The reward for a game is as follows. You get a
   botaction = random.choice(list(avmoves)) reward from the
   server after each move, but it is 0 while the game is running
   loss = -1
   win = +1
   draw = +0.5
   error = -10 (you get this if you try to play in a full column)
   Currently the player always makes the first move
   """

   # default state
   state = np.zeros((6, 7), dtype=int)

   # setup new game
   if vs_server:
      # Start a new game
      res = call_server(-1) # -1 signals the system to start a new game. any running game is counted as a loss

      # This should tell you if you or the bot starts
      print(res.json()['msg'])
      botmove = res.json()['botmove']
      state = np.array(res.json()['state'])
   else:
      # reset game to starting state
      env.reset(board=None)
      # determine first player
      #student_gets_move = random.choice([True, False])
      student_gets_move = False
      if student_gets_move:
         print('You start!')
         print()
      else:
         print('Bot starts!')
         print()

   # Print current gamestate
   #print("Current state (1 are student discs, -1 are servers, 0 is empty): ")
   #print(state)
   #print()

   done = False
   while not done:
      # Select your move
      stmove = student_move(state) # TODO: change input here

      # make both student and bot/server moves
      if vs_server:
         # Send your move to server and get response
         res = call_server(stmove)
         print(res.json()['msg'])

         # Extract response values
         result = res.json()['result']
         botmove = res.json()['botmove']
         state = np.array(res.json()['state'])
      else:
         if student_gets_move:
            # Execute your move
            avmoves = list(env.available_moves())
            if stmove not in avmoves:
               print("You tied to make an illegal move! Games ends.")
               break
            state, result, done, _ = env.step(stmove)

         student_gets_move = True # student only skips move first turn if bot starts

         # print or render state here if you like

         # select and make a move for the opponent, returned reward from students view
         if not done:
            state, result, done = opponents_move(state, env)

      # Check if the game is over
      if result != 0:
         done = True
         if not vs_server:
            print("Game over. ", end="")
         if result == 1:
            print("You won!")
            return True
         elif result == 0.5:
            print("It's a draw!")
            return True
         elif result == -1:
            print("You lost!")
            return False
         elif result == -10:
            print("You made an illegal move and have lost!")
            return False
         else:
            pass
            #print("Unexpected result result={}".format(result))
         if not vs_server:
            print("Final state (1 are student discs, -1 are servers, 0 is empty): ")
      else:
         pass
         #print("Current state (1 are student discs, -1 are servers, 0 is empty): ")

      # Print current gamestate
      #print(state)
      #print()

def main():
   c = 0
   while c <= 20:
      if play_game(vs_server = True):
         c+=1
         print(c)
      else:
         c = 0
         print(f"You lost restart from {c}")
   Print(F"Congrats you have a winning streak of {c}")

if __name__ == "__main__":
    main()
   