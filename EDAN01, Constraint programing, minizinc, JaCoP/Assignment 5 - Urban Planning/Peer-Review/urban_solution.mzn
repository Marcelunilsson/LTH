include "globals.mzn";

include "urban_3.dzn";

int: n;
int: n_commercial;
int: n_residential;
array[1..(n+1)] of int: point_distribution;
set of int: Square = 1..n;

array[Square,Square] of var 0..1: grid;

array[Square] of var int: row_points = [point_distribution[sum(row(grid,i))+1] | i in Square];
array[Square] of var int: col_points = [point_distribution[sum(col(grid,j))+1] | j in Square];
var int: points = sum(row_points ++ col_points);


constraint count(grid,1,n_residential);
constraint lex2(grid);

solve maximize points;

output([
  "grid=\(grid)\n",
  "row_points =\(row_points)\n",
  "points=\(points)\n"]);