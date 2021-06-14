include "globals.mzn";
include "jacop.mzn";

array [1..9] of var 1..9: w;
array [1..9] of string: sa;
sa = ["a", "b", "c", "d", "e", "f", "g", "h", "i"];



constraint
    (2 * w[1] == w[2] + 2*w[3] ) /\
    (2*w[4] + w[5] == w[6]) /\
    (2*w[7]+w[8] == 3*w[9])/\
    (3*(w[1] + w[2] + w[3]) ==2*(w[4]+w[5]+w[6]) + 3*(w[7]+w[8]+w[9]) )/\
    alldifferent(w);  

solve satisfy;

output["\(sa[i]) = \(w[i]);\n" | i in 1..9 ]