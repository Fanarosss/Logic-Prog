% Course: Logic Programming Askisi 2
% Editor: Aslanidis Theofanis

% Knowledge Base:
activity(a01, act(0,3)).
activity(a02, act(0,4)).
activity(a03, act(1,5)).
activity(a04, act(4,6)).
activity(a05, act(6,8)).
activity(a06, act(6,9)).
activity(a07, act(9,10)).
activity(a08, act(9,13)).
activity(a09, act(11,14)).
activity(a10, act(12,15)).
activity(a11, act(14,17)).
activity(a12, act(16,18)).
activity(a13, act(17,19)).
activity(a14, act(18,20)).
activity(a15, act(19,20)).

%arguments: -CP|RP- List to recurse for all players
%           -InitasP- Empty List
%           -ASP- Result
initASP([], _, []).
initASP([CP|RP], InitASP, ASP) :-
  append(InitASP, [CP-[]-0], TempASP),
  initASP(RP, InitASP, RecASP),
  append(TempASP, RecASP, ASP).

%arguments: -CP-ActList-ST- the form of ASP
%           -CPId- Player ID
%           -ActId- Activity ID that will be append
%           -NewASP- updated list
nested_append([CP-ActList-ST|RestCPs], CPId, ActId, NewASP) :-
  %assignment segm
  CP == CPId,
  activity(ActId, act(T01, T02)),
  NewST is ( ST + ( T02 - T01 )),
  append(ActList, [ActId], NewActList),
  append([CP-NewActList-NewST], RestCPs, NewASP).
nested_append([CP-ActList-ST|RestCPs], CPId, ActId, NewASP) :-
  %recursive segm
  CP =\= CPId,
  nested_append(RestCPs, CPId, ActId, RecursiveASP),
  append([CP-ActList-ST], RecursiveASP, NewASP).

%arguments: -CP- Player Id
%           -Id- the activity Id i will check for nointerference
%           -ST- remaining time
%           -RestActivities- all the activities assigned to this one
nointerference(CP, STBound, Id, CP-[]-ST) :-
  activity(Id, act(T01, T02)),
  (( T02 - T01 )  + ST ) =< STBound,!.
nointerference(CP, STBound, Id, CP-[Id1|RestActivities]-ST) :-
  activity(Id, act(T01, T02)),
  activity(Id1, act(T11, T22)),
  (( T01 < T11 , T02 < T11 ) ; ( T02 > T22 , T01 > T22 )),
  nointerference(CP, STBound, Id, CP-RestActivities-ST),!.

%arguments: -CP- current player
%           -ST- remaining time
%           -A- activities assigned for cp
%           -Id- activity to assign
%           -CPId- CP id that I assigned the activity
assign(_, _, [], _, _).
assign(CP, STBound, [CPId-ActList-ST|_], ActId) :-
  CP =:= CPId,
  %compatibility
  nointerference(CP, STBound, ActId, CPId-ActList-ST),!.
assign(CP, STBound, [CPId-_-_|Rest], ActId) :-
  CP =\= CPId,
  %recursion
  assign(CP, STBound, Rest, ActId),!.

%arguments: -N- number of players
%           -ST- Max time
%           -A- activities assigned for all players
%           -L- list with all unasigned activities
distribute_activities(_, _, X_ASP, Y_ASA, [], X_ASP, Y_ASA).
distribute_activities(NP, ST, ASP, ASA, [ActId|L], X_ASP, Y_ASA) :-
  %DFS
  distribute_activities(NP, ST, ASP, ASA, L, R_ASP, R_ASA),
  %activity can be assigned on one of the NP players
  member(CPId, NP),
  assign(CPId, ST, R_ASP, ActId),
  nested_append(R_ASP, CPId, ActId, X_ASP),
  append(R_ASA, [ActId-CPId], Y_ASA).

%between as used in class
between(X1,X2,X1) :-
  X1 =< X2.
between(X1,X2,X) :-
  X1 < X2, NewX1 is X1 + 1,
  between(NewX1, X2, X).

% NP: number of persons, ST: maximum time of working
% ASP: N-A-T, ASA: N-A
assignment(NP, ST, ASP, ASA) :-
  % Let use DFS, to find possible assignments

  % Findall(X, between(), L) gia na ftiaksw ti lista me ta activity
  % Example. L = [a01,a02,a03,a04,....]
  findall(Id, activity(Id, _), L),
  findall(X, between(1, NP, X), ListOfNP),
  initASP(ListOfNP, [], InitASP),
  distribute_activities(ListOfNP, ST, InitASP, [], L, ASP, ASA).

  % ALGORITHM:
  % ---------
  % Kane mia epanalipsi kai anathese drastiriotita se kapoion apo tous NP
  % Mexri afti tin anathesi eimaste simvatoi? An nai sinexizo, an oxi kano alli anathesi
  % An kanei fail, i drastiriotita den mporei na anetethei se kanena
  % Prepei na giriso akoma pio pisw
  % ---------
