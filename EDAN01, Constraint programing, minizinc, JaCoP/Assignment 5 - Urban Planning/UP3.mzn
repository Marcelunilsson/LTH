include"globals.mzn";
%include "urban_1.dzn";
%include "urban_2.dzn";
include "urban_3.dzn";

% Declaring variables from import
int: n;
int: n_commercial;
int: n_residential;
array [1..(n+1)] of int: point_distribution;

% Lets go
array[1..n] of var min(point_distribution)..max(point_distribution): row_points;
array[1..n] of var min(point_distribution)..max(point_distribution): col_points;
var 0..(2*n*max(point_distribution)): totalPoints = sum(row_points) + sum(col_points);
array [1..n, 1..n] of var 0..1: residential;

predicate pointsRowCol(int: index) = point_distribution[sum(residential[index, 1..n])+1] = row_points[index] /\ 
                                    point_distribution[sum(residential[1..n, index])+1] = col_points[index];

constraint forall(index in 1..n)(pointsRowCol(index))  /\
           sum(residential) = n_residential /\
           residential[1, 1] = 1;


solve:: int_search([residential[i, j] | i, j in 1..n] ++ [totalPoints], first_fail, indomain_median, complete) maximize totalPoints;

output["TotalPoints \(totalPoints)"]