import numpy as np


state = np.zeros((6, 7), dtype=int)

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

fourDict, fourList = MakeFourDict(6, 7)
#print(f"fourDict(3, 1): {fourDict[(3, 1)]}")
#print(f"fourDict(5, 5): {fourDict[(5, 5)]}")

def AvaliableMoves(boardState):
   """
   Returns a list of tuples with all the available moves
   """
   return  [(np.count_nonzero(boardState[:, col] == 0) -1, col) for col in list(np.where(boardState[1] == 0))[0]]

#print(AvaliableMoves(state))

def PartVal(four):
   """
   Gives a value based on how close to 4 in a row your moves takes you
   or how much in the way of your opponent getting 4 in a row the move is
   """
   print(f"four: {four}")
   
   oppon, stud, val = four.count(-1), four.count(1), 0
   if oppon == 2 or stud == 2:
      return .6
   else: return 0
   
def MoveVal(boardState, move):
   """
   Counts the total value from all the possible four in a row paths from one move
   dividing the points by how many possible four in a rows the move has
   """
   fourCordList = fourDict[move]
   print(f"fourCordList: {len(fourCordList)}")
   return sum([PartVal(four) for four in [[boardState[coord] for coord in fourCoords] for fourCoords in fourCordList]]) / len(fourCordList)
   



def MakeMove(boardState, player, move):
   """
   updates the boardstate when player makes a move
   """
   np.put(boardState[move[0], :], move[1], player)
   return boardState

#print(MakeMove(state, 1, (5, 5)))

print(MoveVal(state, (4, 4)))