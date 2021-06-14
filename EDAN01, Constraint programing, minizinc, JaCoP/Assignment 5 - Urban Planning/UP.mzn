include"globals.mzn";
%include "urban_1.dzn";
%include "urban_2.dzn";
include "urban_3.dzn";

% Declaring variables from import
int: n;
int: n_commercial;
int: n_residential;
array [1..n+1] of int: point_distribution;

% Lets go
var int: totalPoints;
array [1..n, 1..n] of var 0..1: residential;

totalPoints = sum([point_distribution[sum(residential[i, 1..n])+1]|i in 1..n]) + sum([point_distribution[sum(residential[1..n, i])+1]|i in 1..n]);


% Number of residential
constraint sum(residential) = n_residential /\ lex2(residential);



solve:: int_search([residential[i, j] | i, j in 1..n], first_fail, indomain_min, complete) maximize totalPoints;


output[" Total points: \(totalPoints) \n \(residential)"];

%output[" Total points: \(totalPoints) \n Row 1: \(residential[1, 1..n]) \n Row 2: \(residential[2, 1..n]) \n Row 3: \(residential[2, 1..n]) \n Row 4: \(residential[2, 1..n]) \n Row 5: \(residential[2, 1..n])"]

% COIN-BC 2.10.5/1.17.5
% urban_1.dzn --> Run time: 414ms  , Total points: 14
% urban_2.dzn --> Run time: 410ms  , Total points: 36
% urban_3.dzn --> Run time: 396ms  , Total points: 58

% urban_1.dzn --> Run time: 1s 719ms  , Total points: 14
% urban_2.dzn --> Run time: 954msec  , Total points: 36
% urban_3.dzn --> Run time: ---  , Total points: -