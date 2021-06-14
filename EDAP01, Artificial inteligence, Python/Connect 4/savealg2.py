import gym
import random
import requests
import numpy as np
from gym_connect_four import ConnectFourEnv

from timeit import default_timer as ti

env: ConnectFourEnv = gym.make("ConnectFour-v0")
searchEnv: ConnectFourEnv = gym.make("ConnectFour-v0")
# SERVER_ADRESS = "http://localhost:8000/"
SERVER_ADRESS = "https://vilde.cs.lth.se/edap01-4inarow/"
#SERVER_ADRESS = "http://lavender.blossom.dsek.se:3030/rooms/[hej]/"
API_KEY = 'nyckel'
STIL_ID = ["tfy11mur"]  # TODO: fill this list with your stil-id's


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
   #action = random.choice(list(avmoves))
   #action = student_move(-1 * boardState)
   action = int(input("Opponents move: "))

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
   searchEnv.reset(board = boardState)
   avaMove = list(searchEnv.available_moves())
   if not avaMove:
      env.change_player()  # change back to student before returning
      return -1
   bestMove = avaMove[0]
   maxRew = -100
   for move in avaMove:
      searchState, rew, done, _ = searchEnv.step(move)
      if not done:
         rew = MiniMax(boardState=searchState, depth=4, alpha=-100, beta=100, student=False)
      if rew > maxRew: 
         bestMove = move
         print(f"Best move: {bestMove} \nReward: {rew} \nAvailable moves: {avaMove}")
      maxRew = max(maxRew, rew)
      searchEnv.reset(boardState)
   print(f"Time to think: {ti()-t1} seconds")
   return bestMove


def MiniMax(boardState, depth, alpha, beta, student):
   if depth == 0:
      return 0
   avaMove = list(searchEnv.available_moves())
   if not avaMove:
      return .5
   if student:
      maxp = -100
      for move in avaMove:
         searchEnv.reset(board = boardState) # resets board with player 1
         state, reward, done, _ = searchEnv.step(move) #Make a move3
         if done: 
            return reward
         p = MiniMax(state, depth-1, alpha, beta, False)
         maxp, alpha = max(maxp, p), max(alpha, p)
         if beta <= alpha: return 0   
      return maxp
   else:
      minRew = 100
      for move in avaMove:
         searchEnv.reset(board = boardState) # resets board with player 1
         searchEnv.change_player() # Change to player -1
         state, reward, done, _ = searchEnv.step(move) #make a move
         if done:
            return -reward # if game is over (player -1 won) return -reward
         rew= MiniMax(state, depth-1, alpha, beta, True) # Recursive call 
         minRew, beta = min(minRew, rew), min(beta, rew) # Sets minRew and beta to rew if rev is smaller
         if beta <= alpha: return 0  # if beta is less 
      return minRew
          
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
      # determine first player3
      #student_gets_move = random.choice([True, False])
      student_gets_move = True
      if student_gets_move:
         print('You start!')
         print()
      else:
         print('Bot starts!')
         print()

   # Print current gamestate
   print("Current state (1 are student discs, -1 are servers, 0 is empty): ")
   print(state)
   print()

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
         elif result == 0.5:
            print("It's a draw!")
         elif result == -1:
            print("You lost!")
         elif result == -10:
            print("You made an illegal move and have lost!")
         else:
            print("Unexpected result result={}".format(result))
         if not vs_server:
            print("Final state (1 are student discs, -1 are servers, 0 is empty): ")
      else:
         print("Current state (1 are student discs, -1 are servers, 0 is empty): ")

      # Print current gamestate
      print(state)
      print()

def main():
   play_game(vs_server = False)
   # TODO: Change vs_server to True when you are ready to play against the server
   # the results of your games there will be logged

if __name__ == "__main__":
    main()
