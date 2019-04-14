% Course: Logic Programming Askisi 3
% Editor: Aslanidis Theofanis
% Used Eclipse for the implementation


% we know the set S -> the sum of the starting set S is twice the set of the subsets
% since the subsets S1 and S2 have the same number of elements and the same sum
% if we compute the sum of S (only one time at the beginning) and divide it by two
% we can find the desired Sx (sum) and Sxx (sum of squared) of the subsets.

% I use alldifferent which demands a certain complexity, but I will be sure that all elements
% are unique on both lists. So I can use this information,
% to avoid setting any further constraints for the second subset.

% So having unique elements with alldifferent, I can be sure of a solution, just by
% looking at the sums (Sx and Sxx) of subset S1.

% I use S2 at the recursion just to ensure that:
%    elements are sorted -> avoid duplicate solutions


:- lib(ic).

alldifferent(S1, S2) :-
  append(S1, S2, NewS),
  alldifferent(NewS).

%between as used in class
between(X1,X2,X1) :-
  X1 =< X2.
between(X1,X2,X) :-
  X1 < X2, NewX1 is X1 + 1,
  between(NewX1, X2, X).

% used sx to compute the sum of the set S
sx([], Sx, Sxx, SxTarget, SxxTarget) :-
  SxTarget is Sx//2,
  SxxTarget is Sxx//2.
sx([X|S], Sx, Sxx, SxTarget, SxxTarget) :-
  NewSx is Sx + X,
  NewSxx is Sxx + X*X,
  sx(S, NewSx, NewSxx, SxTarget, SxxTarget).

% empty lists means both lists have the same number of elements
sx_const([], [], _, _, TSx, TSQ, SxTarget, SxxTarget) :-
  TSx $= SxTarget,
  TSQ $= SxxTarget.
%recursively calculates sx and sxx
sx_const([X1|Xs1], [X2|Xs2], X1Prev, X2Prev, TSx, TSQ, SxTarget, SxxTarget):-
  X1Prev $< X1,
  X2Prev $< X2,
  NewTSx $= TSx + X1,
  NewSQ $= TSQ + X1*X1,
  sx_const(Xs1, Xs2, X1, X2, NewTSx, NewSQ, SxTarget, SxxTarget).

constrain(Xs1, Xs2, SxTarget, SxxTarget) :-
  sx_const(Xs1, Xs2, 0, 0, 0, 0, SxTarget, SxxTarget).

% forward checking
hashing(N, N1, N2, S1, S2, SxTarget, SxxTarget) :-
  length(S1, N1),
  length(S2, N2),
  S1 #:: 1..N,
  S2 #:: 2..N,
  alldifferent(S1, S2),
  constrain(S1, S2, SxTarget, SxxTarget),
  generate(S1, S2).

% occurence: selects the entry with the largest number of attached constraints
% indomain_middle: Values are tried beggining from the middle of the domain
generate(S1, S2) :-
  search([S1, S2], 0, occurence, indomain_middle, complete, []).

numpart(N, L1, L2) :-
  N1 is N//2,
  N2 is (N//2 + N mod 2),
  N1 == N2,
  findall(X, between(1, N, X), S),
  sx(S, 0, 0, SxTarget, SxxTarget),
  hashing(N, N1, N2, L1, L2, SxTarget, SxxTarget).
