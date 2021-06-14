include "data_1.dzn";
include "globals.mzn";
include "jacop.mzn";
int: graph_size;   % Number of nodes
int: start;        % Start node 
int: n_dests;       % Number of destinations
array [1..n_dests] of int: dest;  % List of denstinations
int: n_edges;                    % Number of arcs between nodes
array [1..n_edges] of int: from; % Starting nodes for all arcs
array [1..n_edges] of int: to;   % Ending nodes for all arcs
array [1..n_edges] of int: cost; % Distance of each arc

var {1, 2, 3}: x1;
var {2, 3, 4}: x2;
var {3, 5}: x3;
var {4, 5, 6}: x4;
var {5}: x5;
var {6}: x6;

array [1..6] of var int: arr;
arr = [x1, x2, x3, x4, x5, x6];
var 1..100: dist;

constraint
  subcircuit(arr)
  /\
  dist = sum([| i in ]);
  
solve satisfy;

  