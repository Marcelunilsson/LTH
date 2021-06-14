from random import choice
import gym
from gym_connect_four import ConnectFourEnv
import numpy as np
from pathlib import Path

env: ConnectFourEnv = gym.make("ConnectFour-v0")

from solution import alpha_beta_search

names = ['Robo', 'Lisa', 'Eric', 'Dude', 'Bibi', 'Desu', 'Dagu' ]

class Bot:
    def __init__(self, r3, r2):
        self.options = {'r3':r3, 'r2':r2}

        self.name = f"{choice(names)}_{r3}_{r2}"
        
        self.wins = 0
        self.losses = 0
        self.draws = 0
        self.illegals = 0
        self.score = 0.0

    def play(self, state):
        return alpha_beta_search(state, options=self.options)
   
def play_game(p1, p2):
    players = [p1, p2]
    starting = choice([0, 1])
    turn = starting 

    state = np.zeros((6, 7), dtype=int)
    env.reset(board=None)

    done = False
    while not done:
        avmoves = env.available_moves()

        current_state = state
        if turn%2 == 1:
            current_state *= -1
        move = players[turn%2].play(current_state)

        if move not in avmoves:
            # Illegal move
            players[turn%2].illegals += 1
            players[(turn+1)%2].wins += 1
            return 
        
        state, result, done, _ = env.step(move)

        if result != 0:
            done = True

            if result == 1:
                players[turn%2].wins += 1
                players[(turn+1)%2].losses += 1
            elif result == -1:
                players[(turn+1)%2].wins += 1
                players[turn%2].losses += 1
            elif result == 0.5:
                for p in players:
                    p.draws += 1
            elif result == 10:
                players[(turn+1)%2].illegals += 1
                players[turn%2].wins += 1
            elif result == -10:
                players[turn%2].illegals += 1
                players[(turn+1)%2].wins += 1

        turn += 1

def tournament(min_r3=0.1, max_r3=0.9, n_r3=20, min_r2=0.0, max_r2=0.7, n_r2=20):
    bots = list()
    
    for r3 in np.linspace(min_r3, max_r3, num=n_r3):
        for r2 in np.linspace(min_r2, max_r2, num=n_r2):
            bot = Bot(r3, r2)
            bots.append(bot)

    games = 0

    while True:
        # Pit two bots against each other!
        p1 = choice(bots)
        p2 = choice(bots)

        if p1 == p2:
            continue
            
        play_game(p1, p2)
        games += 1

        # Present current standings
        for bot in bots:
            score = bot.wins - bot.losses + 0.5*bot.draws - 10*bot.illegals
            bot.score = float(score)

        bots.sort(key=lambda x: 1000 - x.score)
        
        s = f"Current standings after {games} games:\n"
        for bot in bots[:10]:
            s += f"{expand(bot.name)}: wins: {bot.wins}, draws: {bot.draws}, losses: {bot.losses}, illegals: {bot.illegals}, score={bot.score}\n"
        s += "\n"
        print(s)

        Path('result.tournament').write_text(s)

def expand(s):
    while len(s) < 50:
        s += " "
    return s

if __name__ == "__main__":
    tournament()