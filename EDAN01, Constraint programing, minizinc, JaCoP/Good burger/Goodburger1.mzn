include "burger_data.dzn";
array [beef..tomato] of var 1..5: ing;
array [beef..tomato] of string: na;
na = ["beef", "bun", "cheese", "onions", "pickles", "lettuce", "ketchup", "tomato" ];
%predicate noattack(int: i, var int: ingi) = ingi <= 5 /\ ingi >= 1; % 1 >= nbr ingredient =< 5 of each ingredient

constraint  
      %forall (i in beef..tomato) (noattack(i, ing[i])) /\ % The noattack function
      ing[tomato] == ing[pickles] /\  %same amount of tomato and pickles
      ing[ketchup] == ing[lettuce] /\  % same amount of ketchup and lettuce
      sum(i in beef..tomato)(ing[i] * sodium[i]) < 3000 /\ % Sum of all sodium in the recipe is less than 3000 mg
      sum(i in beef..tomato)(ing[i] * fat[i]) < 150 /\ % Sum of all fat in the recipe is less than 150 g
      sum(i in beef..tomato)(ing[i] * calories[i]) < 3000; % Sum of all calories in the recipe is less than 3000 


solve maximize sum(i in beef..tomato)(ing[i] * cost[i]); % solve for maximizing the cost


output[ show(sum(i in beef..tomato)(ing[i] * cost[i]) ) ] ++ ["\n"] ++ ["\(na[i]) = \(ing[i]);\n" | i in beef..tomato ] % print the cost and the number of ingredients
