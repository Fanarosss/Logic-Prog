% Course: Logic Programming Askisi 5
% Editor: Aslanidis Theofanis
% AM : 1115201500013
% Used Eclipse for the implementation

:- lib(ic).
:- lib(branch_and_bound).

% Knowledge Base:
activity(a001, act(41,49)).
activity(a002, act(72,73)).
activity(a003, act(80,85)).
activity(a004, act(65,74)).
activity(a005, act(96,101)).
activity(a006, act(49,55)).
activity(a007, act(51,59)).
activity(a008, act(63,65)).
activity(a009, act(66,69)).
activity(a010, act(80,87)).
activity(a011, act(71,76)).
activity(a012, act(64,68)).
activity(a013, act(90,93)).
activity(a014, act(49,56)).
activity(a015, act(23,29)).
activity(a016, act(94,101)).
activity(a017, act(25,34)).
activity(a018, act(51,54)).
activity(a019, act(13,23)).
activity(a020, act(67,72)).
activity(a021, act(19,21)).
activity(a022, act(12,16)).
activity(a023, act(99,104)).
activity(a024, act(92,94)).
activity(a025, act(74,83)).
activity(a026, act(95,100)).
activity(a027, act(39,47)).
activity(a028, act(39,49)).
activity(a029, act(37,39)).
activity(a030, act(57,66)).
activity(a031, act(95,101)).
activity(a032, act(71,74)).
activity(a033, act(86,93)).
activity(a034, act(51,54)).
activity(a035, act(74,83)).
activity(a036, act(75,81)).
activity(a037, act(33,43)).
activity(a038, act(29,30)).
activity(a039, act(58,60)).
activity(a040, act(52,61)).
activity(a041, act(35,39)).
activity(a042, act(46,51)).
activity(a043, act(71,72)).
activity(a044, act(17,24)).
activity(a045, act(94,103)).
activity(a046, act(77,87)).
activity(a047, act(83,87)).
activity(a048, act(83,92)).
activity(a049, act(59,62)).
activity(a050, act(2,4)).
activity(a051, act(86,92)).
activity(a052, act(94,103)).
activity(a053, act(80,81)).
activity(a054, act(39,46)).
activity(a055, act(60,67)).
activity(a056, act(72,78)).
activity(a057, act(58,61)).
activity(a058, act(8,18)).
activity(a059, act(12,16)).
activity(a060, act(47,50)).
activity(a061, act(49,50)).
activity(a062, act(71,78)).
activity(a063, act(34,42)).
activity(a064, act(21,26)).
activity(a065, act(92,95)).
activity(a066, act(80,81)).
activity(a067, act(74,79)).
activity(a068, act(28,29)).
activity(a069, act(100,102)).
activity(a070, act(29,37)).
activity(a071, act(4,12)).
activity(a072, act(79,83)).
activity(a073, act(98,108)).
activity(a074, act(91,100)).
activity(a075, act(82,91)).
activity(a076, act(59,66)).
activity(a077, act(34,35)).
activity(a078, act(51,60)).
activity(a079, act(92,94)).
activity(a080, act(77,83)).
activity(a081, act(38,48)).
activity(a082, act(51,59)).
activity(a083, act(35,39)).
activity(a084, act(22,24)).
activity(a085, act(67,68)).
activity(a086, act(90,97)).
activity(a087, act(82,83)).
activity(a088, act(51,53)).
activity(a089, act(78,88)).
activity(a090, act(74,79)).
activity(a091, act(100,105)).
activity(a092, act(53,63)).
activity(a093, act(57,66)).
activity(a094, act(32,41)).
activity(a095, act(48,56)).
activity(a096, act(92,96)).
activity(a097, act(4,8)).
activity(a098, act(31,33)).
activity(a099, act(69,77)).
activity(a100, act(88,93)).


%arguments: -CP|RP- List to recurse for all players
%           -InitasP- Empty List
%           -ASP- Result
initASP([], _, []).
initASP([CP|RP], InitASP, ASP) :-
  append(InitASP, [CP-[]-0], TempASP),
  initASP(RP, InitASP, RecASP),
  append(TempASP, RecASP, ASP).

% total duration of Activities
duration([], D, D).
duration([ActId|RestActivities], CurrentDuration, D) :-
  activity(ActId, act(T01, T02)),
  NewDuration is (CurrentDuration + (T02 - T01)),
  duration(RestActivities, NewDuration, D).

%between as used in class
between(X1,X2,X1) :-
  X1 =< X2.
between(X1,X2,X) :-
  X1 < X2, NewX1 is X1 + 1,
  between(NewX1, X2, X).

% custom sum
my_sum(_, [], Cost, Cost).
my_sum(A, [CP-ActList-Wi|RestASP], CurrentCost, Cost) :-
  NewCost $= CurrentCost + (A - Wi)*(A - Wi),
  my_sum(A, RestASP, NewCost, Cost).

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


nointerference(CP, STBound, Id, CP-[]-ST) :-
  activity(Id, act(T01, T02)),
  (( T02 - T01 )  + ST ) #=< STBound.
nointerference(CP, STBound, Id, CP-[Id1|RestActivities]-ST) :-
  activity(Id, act(T01, T02)),
  activity(Id1, act(T11, T22)),
  (( T01 < T11 , T02 < T11 ) ; ( T02 > T22 , T01 > T22 )),
  nointerference(CP, STBound, Id, CP-RestActivities-ST).

find_person_ASP(_, [], _).
find_person_ASP(CP, [CPid-ActList-CPST|_], CP-ActList-CPST) :-
  CP == CPid.
find_person_ASP(CP, [CPid-_-_|ASP], TempASP) :-
  CP =\= CPid,
  find_person_ASP(CP, ASP, TempASP).


find_person([], _, _, _, _, _).
find_person([CP|RestCPs], ASP, X, ST, ActId, NewASP) :-
  find_person_ASP(CP, ASP, CP-ActList-CPST),
  nointerference(CP, ST, ActId, CP-ActList-CPST),
  nested_append(ASP, CP, ActId, NewASP),
  X $= CP.
find_person([CP|RestCPs], ASP, X, ST, ActId, NewASP) :-
  find_person_ASP(CP, ASP, CP-ActList-CPST),
  not nointerference(CP, ST, ActId, CP-ActList-CPST),
  X $\= CP,
  find_person(RestCPs, ASP, X, ST, ActId, NewASP).


constraints(NewASP, [], _, [], NewASP).
constraints(ASP, [X|S], ST, [ActId|L], RecASP) :-
  get_domain_as_list(X, CPList),
  find_person(CPList, ASP, X, ST, ActId, NewASP),
  constraints(NewASP, S, ST, L, RecASP).


assignment_csp(NP, ST, ASP, ASA) :-
  % Findall(X, between(), L) gia na ftiaksw ti lista me ta activity
  % Example. L = [a01,a02,a03,a04,....]
  findall(Id, activity(Id, _), L),
  length(L,ActivityNum),
  findall(X, between(1, NP, X), ListOfNP),
  initASP(ListOfNP, [], InitASP),
  length(S, ActivityNum), % variable logical domain
  S #:: 1..NP,
  % constraints:
  %   - person work time < ST
  %   - no activities interfering
  constraints(InitASP, S, ST, L, ASP),
  search(S, 0, occurence, indomain_middle, complete, []).
  % convert solution to asa and exit

assignment_opt(NF, NP, ST, F, T, ASP, ASA, Cost) :-
  % Findall(X, between(), L) gia na ftiaksw ti lista me ta activity
  % Example. L = [a01,a02,a03,a04,....]
  findall(Id, activity(Id, _), L),
  duration(L, 0, D),
  Afloat is round(D/NP),
  A is integer(Afloat),
  length(L,ActivityNum),
  findall(X, between(1, NP, X), ListOfNP),
  initASP(ListOfNP, [], InitASP),
  length(S, ActivityNum), % variable logical domain
  S #:: 1..NP,
  % constraints:
  %   - person work time < ST
  %   - no activities interfering
  constraints(InitASP, S, ST, L, ASP),
  my_sum(A, ASP, 0, Cost),
  bb_min(search(S, 0, occurence, indomain_middle, complete, []), Cost, bb_options{strategy:restart, timeout:T}).
  % convert solution to asa and exit
