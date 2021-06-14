include "globals.mzn";
include "urban_3.dzn"; %including the files makes it easyer to run

% ------------ Input Variables ------------
int : n;
int : n_commercial;
int : n_residential;
array[1..n + 1] of int : point_distribution;

% Constants
int : min_s = min(point_distribution);
int : max_s = max(point_distribution);

% ----------- Domain Variables ------------

% Comerical 0, Residential 1.
array[1..n, 1..n] of var 0..1 : grid;
array[1..n] of var min_s..max_s : r_score;
array[1..n] of var min_s..max_s : c_score;
var (min_s * 2 * n)..(max_s * 2 * n) : score;

% ------------- Constraints ---------------

% Every res needs to be in the matrix.
constraint(sum(grid) == n_residential);

% Score for each row and column. Calculated by the amount of residental houses. + 1 to account for the 1..n + 1 point_dist array.
constraint forall(i in 1..n)(r_score[i] == point_distribution[sum([grid[i, j] | j in 1..n]) + 1]);
constraint forall(i in 1..n)(c_score[i] == point_distribution[sum([grid[j, i] | j in 1..n]) + 1]);

% Symmetry breaking constraint.
constraint lex2(grid);

% Final Score.
constraint score == (sum(r_score) + sum(c_score));

solve maximize score; % Implementing a search algorithm like int_search([residential[i, j] | i, j in 1..n], first_fail, indomain_max, complete) would make it faster 
%solve:: int_search([grid[i, j] | i, j in 1..n], first_fail, indomain_max, complete) maximize score;
output["Area: \n" ++ show2d(grid) ++ "\nScore: " ++ show(score)] 