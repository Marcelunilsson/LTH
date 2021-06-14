include "data_1.dzn";
include "globals.mzn";
int: n;         % def Number of ppl                                                                                                                                                                                                                                                                                                                                                                             
int: n_prefs;  % def number of preferences
array[1..n_prefs, 1..2] of int: prefs; % def list of preferences
array[1..n] of var 1..n: pl;  % def list of placement, (index, value) = (person, place)
var 0..n: mp;  % def variable for counting how far each pref is from the real placement

constraint
  alldifferent(pl) % two cant sit on the same space
 % /\ mp = max(i in 1..n_prefs)(abs(pl[prefs[i, 1]]-pl[prefs[i, 2]])); % sums up the total difference between preference and real placements
  /\ mp = max([abs(pl[prefs[i, 1]]-pl[prefs[i, 2]]) | i in 1..n_prefs]);
   
  

solve minimize mp; % solve to minimize the total difference between preference and real placements

output[show(mp)] % show result