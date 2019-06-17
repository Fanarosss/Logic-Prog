% Course: Logic Programming Askisi 5
% Editor: Aslanidis Theofanis
% AM : 1115201500013
% Used Eclipse for the implementation
% !!! Ta ilopoiisa ola apla eixa ena thema ston elegxo na min kanoun interfere oi xronoi
% tou idiou atoma, exo ftiakei ti sinartisi kai exo vgalei kai tipota gia to pote kanoun
% interfere. T01 + T02 - (T11 + T12) pairno to absolute autis tis diaforas kai afairw to maximum
% apo tis dio diafores T01-T02 kai T11+T12, opote o vazw oles tis ic metavlites me tis times se mia lista
% kai thelw to min tis listas na einai megalitero tou 0, ama einai mikrotero, simainei oti 2 activities kanoun
% overlap stous xronous tous.

% ola ta ipoloipa mou doulevoun kala.
% Exo xrisimopoiisei reified constraints, exontas to S poy exei gia kathe activity poios tin exei
% kai to CurrPersonsActList poy pernei [0,1] times kai einai gia kathe anthropo, poia activity exei parei.

:- lib(ic).
:- lib(branch_and_bound).

%arguments: -CP|RP- List to recurse for all players
%           -InitasP- Empty List
%           -ASP- Result
initASP([], _, Persons_ST, [], Persons_ST).
initASP([CP|RP], InitASP, STList, ASP, Persons_ST) :-
  append(STList, [0], NewSTList),
  append(InitASP, [CP-[]-0], TempASP),
  initASP(RP, InitASP, NewSTList, RecASP, Persons_ST),
  append(TempASP, RecASP, ASP).


assign_to_person(X, ActId, [CP-ActList-ST|RecASP], ASP) :-
  X == CP,
  activity(ActId, act(T0,T1)),
  NewST is ST + T1 - T0,
  append([ActId], ActList, NewActList),
  append([CP-NewActList-NewST], RecASP, ASP).
assign_to_person(X, ActId, [CP-ActList-ST|RecASP], ASP) :-
  X =\= CP,
  assign_to_person(X, ActId, RecASP, TempASP),
  append([CP-ActList-ST], TempASP, ASP).

convert_solution_to_ASP([], [], InitASP, InitASP).
convert_solution_to_ASP([X|S], [ActId|L], InitASP, ASP) :-
  convert_solution_to_ASP(S, L, InitASP, RecASP),
  assign_to_person(X, ActId, RecASP, ASP).


convert_solution_to_ASA([], [], []).
convert_solution_to_ASA([X|S], [ActId|L], ASA) :-
  convert_solution_to_ASA(S, L, RecASA),
  append([ActId-X], RecASA, ASA).

% total duration of Activities
duration([], D, D).
duration([ActId|RestActivities], CurrentDuration, D) :-
  activity(ActId, act(T01, T02)),
  NewDuration is (CurrentDuration + (T02 - T01)),
  duration(RestActivities, NewDuration, D).

% functions to keep the first NF
iterate(_, _, [], []).
iterate(CF, NF, [C|TempL], L) :-
  CF < NF,
  CNF is CF + 1,
  iterate(CNF, NF, TempL, RecL),
  append(RecL, [C], L).
iterate(CF, NF, _, []) :-
  CF >= NF.

keep_first_NF(NF, TempL, L) :-
  NF =\= 0,
  iterate(0, NF, TempL, L).
keep_first_NF(0, L, L).

%between as used in class
between(X1,X2,X1) :-
  X1 =< X2.
between(X1,X2,X) :-
  X1 < X2, NewX1 is X1 + 1,
  between(NewX1, X2, X).

compute_st(_, [], [], 0).
compute_st(A, [X|ActList], [ActId|RestActivities], ST) :-
  compute_st(A, ActList, RestActivities, RecST),
  activity(ActId, act(T01, T02)),
  ActTime is T02 - T01,
  ST #= eval(RecST + X * ActTime).

% CostList
my_sum(_, _, _, [], []).
my_sum(A, S, L, [CPacts|ActLists], [ST|CostList]) :-
  compute_st(A, CPacts, L, Wi),
  ST #= sqr(eval((A-Wi))),
  my_sum(A, S, L, ActLists, CostList).

initCPList(_, [], []).
initCPList(CurrPerson, [CPAct|RestList], [CP|S]) :-
  initCPList(CurrPerson, RestList, S),
  CP #\= CurrPerson => CPAct #= 0.

time_max(X,Y,X) :- X >= Y, !.
time_max(_,Y,Y).

absolute(X, Y) :- X < 0, Y is -1*X, !.
absolute(X, X).


apply_constraint(_, [], [], _, _, []).
apply_constraint(CPAct, [CPAct2|RestList], [ActId|L], T01, T02, [P|Overlapping]) :-
  activity(ActId, act(T11, T12)),
  ActTime1 is T02 - T01,
  ActTime2 is T12 - T11,
  time_max(ActTime1, ActTime2, Max),
  Computation is T01 + T02 - T11 - T12,
  AbsoluteV is absolute(Computation),
  P #= eval(CPAct*CPAct2*(AbsoluteV-Max)),
  apply_constraint(CPAct, RestList, L, T01, T02, Overlapping).

constraint2(_, [], [], [], _, _).
constraint2(CurrPerson, [CPAct|RestList], [CP|S], [ActId|L], RecCPAs, ActList) :-
  constraint2(CurrPerson, RestList, S, L, RecCPAs, ActList),
  activity(ActId, act(T01, T02)),
  apply_constraint(CPAct, RecCPAs, ActList, T01, T02, OverlappingList),
  min(OverlappingList) #= 0.


constraint1(_, [], [], [], 0).
constraint1(CurrPerson, [CPAct|RestList], [CP|S], [ActId|L], Sum) :-
  constraint1(CurrPerson, RestList, S, L, CurrSum),
  activity(ActId, act(T01, T02)),
  CP #= CurrPerson => CPAct #= 1,
  ActTime is T02 - T01,
  Sum #= eval(CurrSum + CPAct*ActTime).

constraints([], _, _, _, _).
constraints([CurrPerson|RestPersons], S, ST, L, [CurrPersonsActList|ActLists]) :-
  length(L, ActivityNum),
  length(CurrPersonsActList, ActivityNum),
  % a list with the activities that this person has. 0 for not having, 1 for having.
  CurrPersonsActList #:: 0..1,
  initCPList(CurrPerson, CurrPersonsActList, S),
  constraint1(CurrPerson, CurrPersonsActList, S, L, Sum),
  Sum #=< ST,
  % I had a problem in this function so I commented it.
  %constraint2(CurrPerson, CurrPersonsActList, S, L, CurrPersonsActList, L),
  constraints(RestPersons, S, ST, L, ActLists).


assignment_csp(NP, ST, ASP, ASA) :-
  % Findall(X, between(), L) gia na ftiaksw ti lista me ta activity
  % Example. L = [a01,a02,a03,a04,....]
  findall(Id, activity(Id, _), L),
  length(L,ActivityNum),
  findall(X, between(1, NP, X), ListOfNP),
  initASP(ListOfNP, [], [], InitASP, Persons_ST),
  length(S, ActivityNum),
  S #:: 1..NP,
  % constraints:
  %   - person work time < ST
  %   - no activities interfering
  constraints(ListOfNP, S, ST, L, ActLists),
  search(S, 0, first_fail, indomain, complete, []),
  convert_solution_to_ASP(S, L, InitASP, ASP),
  convert_solution_to_ASA(S, L, ASA).
  % convert solution to asp and asa and exit

assignment_opt(NF, NP, ST, F, T, ASP, ASA, Cost) :-
  % Findall(X, between(), L) gia na ftiaksw ti lista me ta activity
  % Example. L = [a01,a02,a03,a04,....]
  findall(Id, activity(Id, _), TempL),
  keep_first_NF(NF, TempL, L),
  duration(L, 0, D),
  Afloat is round(D/NP),
  A is integer(Afloat),
  length(L,ActivityNum),
  findall(X, between(1, NP, X), ListOfNP),
  initASP(ListOfNP, [], [], InitASP, Persons_ST),
  length(S, ActivityNum),
  S #:: 1..NP,
  % constraints:
  %   - person work time < ST
  %   - no activities interfering
  constraints(ListOfNP, S, ST, L, ActLists),
  my_sum(A, S, L, ActLists, CostList),
  Cost #= sum(CostList),
  write(Cost),nl,
  bb_min(search(S, 0, first_fail, indomain, complete, []), Cost, bb_options{strategy:restart, factor:F, timeout:T}),
  convert_solution_to_ASP(S, L, InitASP, ASP),
  convert_solution_to_ASA(S, L, ASA).
  % convert solution to asa and exit
