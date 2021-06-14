include "data_1.dzn";
include "globals.mzn";
int: n;   % def Number of ppl                                                                                                                                                                                        
int: n_prefs; % def number of preferences
array[1..n_prefs, 1..2] of int: prefs; % def list of preferences
array[1..n] of var 1..n: pl; % def list of placement, (index, value) = (person, place)
var 0..n_prefs: mp; % def variable for counting placements next to each other

constraint
  alldifferent(pl) % two cant sit on the same space
  /\  mp = sum(i in 1..n_prefs)(abs(pl[prefs[i, 1]]-pl[prefs[i, 2]]) == 1 ); % sums all the people siting next to each other that also had a preference to do so
  

solve maximize mp; % solve for maximising the number of preferences fullfilled

output[show(mp)] % show result