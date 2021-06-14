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
array [1..graph_size] of var int: x;
x = [|i in 1..n_edges]