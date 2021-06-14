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
var int: cost;
%list of durations for adders and multipliers
array [1..n] of int: Durations = [if (i in add) then del_add else del_mul endif | i in 1..n];

%List of Starttimes
array [1..n] of var 0..max([del_mul, del_add])*n: Starttimes;

% Different domains for adders and multipliers
array [1..n] of var 1..(number_add+number_mul): Resource_origins;
constraint forall(i in 1..n) (if (i in add) then Resource_origins[i] <= (number_add) else Resource_origins[i] > (number_add) endif );

%Resourses list
array [1..n] of int: Resources = [1|i in 1..n];


%add dependancies
predicate beforeDependencies(set of int:dep, int:action ) = forall(i in dep)(Starttimes[action] + Durations[action] <= Starttimes[i]);

constraint   forall(i in 1..n)(beforeDependencies(dependencies[i], i)) /\ 
                diff2(Starttimes, Resource_origins, Durations, Resources) /\
                forall(i in last)(Starttimes[i] + Durations[i] <= cost);


solve:: int_search(Starttimes, first_fail, indomain_min, complete) minimize cost;

output["Resource_origins: \(Resource_origins)  \n Starttimes: \(Starttimes) \n Durations:  \(Durations) \n \(cost)"];
