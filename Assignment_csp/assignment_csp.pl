% Course: Logic Programming Askisi 5
% Editor: Aslanidis Theofanis
% AM : 1115201500013
% Used Eclipse for the implementation

:- lib(ic).
:- lib(branch_and_bound).
:- lib(listut).

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

% custom sum
my_sum(_, [], [], Sol, L, 0).
my_sum(A, [X|S], [ActId|RestActivities], Sol, L, Cost) :-
  my_sum(A, S, RestActivities, Sol, L, CurrCost),
  activity(ActId, act(T01, T02)),
  compute_st(X, Sol, L, T01, T02, 0, Wi),
  Cost #= eval(CurrCost + (A - Wi)*(A - Wi)).


compute_st(_, [], [], _, _, ST, ST).
compute_st(X, [CP|S], [ActId|L], T01, T02, CurrST, ST) :-
  get_domain_size(CP,Size),
  Size == 1,
  X #= CP,
  activity(ActId, act(T11, T12)),
  NewST is CurrST + T12 - T11,
  compute_st(X, S, L, T01, T02, NewST, ST).
compute_st(X, [CP|S], [ActId|L], T01, T02, CurrST, ST) :-
  get_domain_size(CP,Size),
  Size == 1,
  X #\= CP,
  compute_st(X, S, L, T01, T02, CurrST, ST).
compute_st(X, [CP|S], [ActId|L], T01, T02, CurrST, ST) :-
  get_domain_size(CP,Size),
  Size > 1,
  compute_st(X, S, L, T01, T02, CurrST, ST).

test(X, ST, ActId, S, L) :-
  activity(ActId, act(T01, T02)),
  %compute current time of person
  compute_st(X, S, L, T01, T02, 0, CurrST),
  CurrST #=< ST.

constraints([], _, [], _, _).
constraints([X|S], ST, [ActId|L], Sol, ActList) :-
  indomain(X),
  test(X, ST, ActId, Sol, ActList),
  constraints(S, ST, L, Sol, ActList).


assignment_csp(NP, ST, ASP, ASA) :-
  % Findall(X, between(), L) gia na ftiaksw ti lista me ta activity
  % Example. L = [a01,a02,a03,a04,....]
  findall(Id, activity(Id, _), L),
  length(L,ActivityNum),
  findall(X, between(1, NP, X), ListOfNP),
  initASP(ListOfNP, [], [], InitASP, Persons_ST),
  length(S, ActivityNum), % variable logical domain
  S #:: 1..NP,
  % constraints:
  %   - person work time < ST
  %   - no activities interfering
  constraints(S, ST, L, S, L),
  search(S, 0, occurence, indomain_middle, complete, []),
  convert_solution_to_ASP(S, L, InitASP, ASP),
  convert_solution_to_ASA(S, L, ASA).
  % convert solution to asa and exit

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
  length(S, ActivityNum), % variable logical domain
  S #:: 1..NP,
  % constraints:
  %   - person work time < ST
  %   - no activities interfering
  bb_min((constraints(S, ST, L, S, L), my_sum(A, S, L, S, L, Cost)), Cost, bb_options{strategy:restart, factor:F, from: 0, timeout:T}),
  convert_solution_to_ASP(S, L, InitASP, ASP),
  convert_solution_to_ASA(S, L, ASA).
  % convert solution to asa and exit
