include "globals.mzn";
include "ar_1_1.dzn";
% Delays
int : del_add;
int : del_mul;
%Number of adders and multipliers
int : number_add;
int : number_mul;
%number of actions
int : n;
%Last actions to be performed
set of int : last;
%sets of add and mul action indexes
set of int : add;
set of int : mul;
%array of sets of dependencies for the index action
array[1..n] of set of int : dependencies;

% Start of my code
var int:cost;
array[1..n] of var int: StartTime;
array[1..length(add)] of var 0..1000: add_time;
array[1..length(add)] of var 1..number_add: add_alloc;
array[1..length(add)] of int: add_dur = [del_add|i in 1..length(add)];
array[1..length(add)] of int: add_resources = [1|i in 1..length(add)];

array[1..length(mul)] of var 0..1000: mul_time;
array[1..length(mul)] of var 1..number_mul: mul_alloc;
array[1..length(mul)] of int: mul_dur = [del_mul|i in 1..length(mul)];
array[1..length(mul)] of int: mul_resources = [1|i in 1..length(mul)];

array[1..n] of var 1..2: Durations = [if exists(j in 1..length(add))(i == add[j]) then del_add else del_mul endif | i in 1..n];

constraint forall(i in 1..length(mul))(StartTime[mul[i]] = mul_time[i]);
constraint forall(i in 1..length(add))(StartTime[add[i]] = add_time[i]);

constraint forall(i in 1..n, j in dependencies[i])(StartTime[i] + Durations[i] <= StartTime[j]);
constraint forall(i in last)(StartTime[i] + Durations[i] <= cost);

constraint diffn(add_time, add_alloc, add_dur, add_resources);
constraint diffn(mul_time, mul_alloc, mul_dur, mul_resources);

constraint cumulative(add_time, add_dur, add_resources, number_add);
constraint cumulative(mul_time, mul_dur, mul_resources, number_mul);

solve:: int_search(StartTime, first_fail, indomain_min, complete) minimize cost;

output["Clock cycles: \(cost)"];