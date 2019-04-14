% Course: Logic Programming Askisi 3
% Editor: Aslanidis Theofanis
% Used Eclipse for the implementation

:- lib(ic).

alldifferent(S1, S2) :-
  append(S1, S2, NewS),
  alldifferent(NewS).

% empty lists means both lists have the same number of elements
sx_const([], [], _, _, TSx1, TSx2, TSQ1, TSQ2) :-
  TSx1 $= TSx2,
  TSQ1 $= TSQ2.
%recursively calculates sx and sxx
sx_const([X1|Xs1], [X2|Xs2], X1Prev, X2Prev, TSx1, TSx2, TSQ1, TSQ2):-
  X1Prev $< X1,
  X2Prev $< X2,
  NewTSx1 $= TSx1 + X1,
  NewTSx2 $= TSx2 + X2,
  NewSQ1 $= TSQ1 + X1*X1,
  NewSQ2 $= TSQ2 + X2*X2,
  sx_const(Xs1, Xs2, X1, X2, NewTSx1, NewTSx2, NewSQ1, NewSQ2).

constrain(Xs1, Xs2) :-
  sx_const(Xs1, Xs2, 0, 0, 0, 0, 0, 0).

% forward checking
hashing(N, N1, N2, S1, S2) :-
  length(S1, N1),
  length(S2, N2),
  S1 #:: 1..N,
  S2 #:: 2..N,
  alldifferent(S1, S2),
  constrain(S1, S2),
  generate(S1, S2).

generate(S1, S2) :-
  search([S1, S2], 0, occurence, indomain_middle, complete, []).

numpart(N, L1, L2) :-
  N1 is N//2,
  N2 is (N//2 + N mod 2),
  N1 == N2,
  hashing(N, N1, N2, L1, L2).
