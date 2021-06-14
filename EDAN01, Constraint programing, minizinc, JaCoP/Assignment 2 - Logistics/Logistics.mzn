include "data_3.dzn";
include "globals.mzn";
%include "jacop.mzn";

% Initiating variables from data
int: graph_size;   % Number of nodes
int: start;        % Start node 
int: n_dests;       % Number of destinations
int: n_edges;                    % Number of arcs between nodes

% Initiating Lists from data
array [1..n_dests] of int: dest;  % List of denstinations
array [1..n_edges] of int: from; % Starting nodes for all arcs
array [1..n_edges] of int: to;   % Ending nodes for all arcs
array [1..n_edges] of int: cost; % Distance of each arc


% Reformatting and creating lists for calculations (network_flow(arcs, balance, flow))
array [1..2*n_edges] of int: cost2;
cost2 = cost ++ cost; % Making the Cost list double the length to handle arcs in both directions

array [1..graph_size] of int: balance; % Balance is the outflow of each node, 1 for start(Source), -1 for destinations(Drain), 0 for all other nodes
balance = [if i == start then n_dests elseif i in array2set(dest) then -1 else 0 endif | i in 1..graph_size]; 

array [1..2*n_edges, 1..2] of int: arcs; % A list of all the arcs, added in both directions
arcs = array2d(1..2*n_edges, 1..2, [(1 - j) * from[i] + j * to[i] | i in 1..n_edges, j in 0..1] ++ [(1 - j) * to[i] + j * from[i] | i in 1..n_edges, j in 0..1]);

% Variables to calculate
array [1..2*n_edges] of var 0..n_dests: flow;
var int: dist;

constraint
  network_flow(arcs, balance , flow)
  /\
  dist = sum([if (flow[i] > 0) then cost2[i] else 0 endif | i in 1..2*n_edges]); 
  
 solve minimize dist;

output[show(dist)]