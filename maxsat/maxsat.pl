% Course: Logic Programming Askisi 3
% Editor: Aslanidis Theofanis
% Used Eclipse for the implementation

:- lib(ic).
:- lib(branch_and_bound).

% given code in order to create formula
create_formula(NVars, NClauses, Density, Formula) :-
   formula(NVars, 1, NClauses, Density, Formula).

formula(_, C, NClauses, _, []) :-
   C > NClauses.
formula(NVars, C, NClauses, Density, [Clause|Formula]) :-
   C =< NClauses,
   one_clause(1, NVars, Density, Clause),
   C1 is C + 1,
   formula(NVars, C1, NClauses, Density, Formula).

one_clause(V, NVars, _, []) :-
   V > NVars.
one_clause(V, NVars, Density, Clause) :-
   V =< NVars,
   rand(1, 100, Rand1),
   (Rand1 < Density ->
      (rand(1, 100, Rand2),
       (Rand2 < 50 ->
        Literal is V ;
        Literal is -V),
       Clause = [Literal|NewClause]) ;
      Clause = NewClause),
   V1 is V + 1,
   one_clause(V1, NVars, Density, NewClause).

rand(N1, N2, R) :-
   random(R1),
   R is R1 mod (N2 - N1 + 1) + N1.
% end of given code

% comparing list length
longer_than(X,Y) :-
  length(X,Xlen),
  length(Y,Ylen),
  Xlen > Ylen.

%quicksort for sorting a list of lists of lists lengths
sort_by_len([], []).
sort_by_len([X|Tail], Sorted) :-
  split(X, Tail, Small, Big),
  sort_by_len(Small, SortedSmall),
  sort_by_len(Big, SortedBig),
  append(SortedSmall, [X|SortedBig], Sorted).
split(X, [], [], []).
split(X, [Y|Tail], [Y|Small], Big) :-
  longer_than(X, Y),
  !,
  split(X, Tail, Small, Big).
split(X, [Y|Tail], Small, [Y|Big]) :-
  split(X, Tail, Small, Big).

% function that goes over the list to put a constrain
% on the binary variable S, and returning the constrain,
% 1 for true, 0 for false
find_value(_, [], 0).
find_value(Term, Index, [_|Rest], R) :-
  Term > 0,
  Term \= Index,
  IncIndex is Index + 1,
  find_value(Term, IncIndex, Rest, R).
find_value(Term, Index, [_|Rest], R) :-
  Term < 0,
  Term \= -1*Index,
  IncIndex is Index + 1,
  find_value(Term, IncIndex, Rest, R).
find_value(Term, Index, [CS|_], 1) :-
  Term =:= Index,
  Term > 0,
  CS #= 1.
find_value(Term, Index, [CS|_], 0) :-
  Term =:= Index,
  Term > 0,
  CS #= 0.
find_value(Term, Index, [CS|_], 1) :-
  Term =:= -1*Index,
  Term < 0,
  CS #= 0.
find_value(Term, Index, [CS|_], 0) :-
  Term =:= -1*Index,
  Term < 0,
  CS #= 1.

% optimization function in order to call find_value
% only one time at evaluate_term (and not two if the V constrain fails)
decide(Rest, S, V, Value) :-
  V #= 0,
  evaluate_term(Rest, S, Value).
decide(_, _, V, V) :-
  V #= 1.

% evaluate the proposition, whether it can be true
% at first true term it stops and goes back
% if all terms are false -> proposition is false -> cost is incremented
evaluate_term([], _, 0).
evaluate_term([Term|Rest], S, Value) :-
  find_value(Term, 1, S, V),
  decide(Rest, S, V, Value).

set_cost(Value, CurrM, CurrM) :-
  Value #= 1.
set_cost(Value, CurrM, NewM) :-
  Value #= 0,
  NewM #= CurrM + 1.

% evaluating the propositions
proposition_calc([], _, M, M).
proposition_calc([CF|Rest], S, CurrM, M) :-
  evaluate_term(CF, S, Value),
  set_cost(Value, CurrM, NewM),
  proposition_calc(Rest, S, NewM, M).

% NV variables
% NC propositions
% D density
% F sequence of propositions
% S solution list with true or false
% M num of true propositions
maxsat(NV, NC, D, F, S, M) :-
  create_formula(NV, NC, D, F),
  sort_by_len(F, SortedF),
  length(S, NV),% variable logical domain
  S #:: 0..1,
  % Cost is the number of false propositions
  % -> optimizing the number of falses ->
  % means we have the most true propositions
  bb_min(proposition_calc(SortedF, S, 0, Cost), Cost, bb_options{strategy:restart, from:0}),
  M is NC - Cost.
