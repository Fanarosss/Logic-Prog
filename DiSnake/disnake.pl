% Course: 	Logic Programming, Askisi 1
% Editor: 	Aslanidis Theofanis

% I worked between 2 functions, forward and backward

% forward_create
% ------------->
% backward_create
% <-------------

% At forward and backward create, who write the lines
% Width and Pattern arguments are stable in order to reset:
% 1) at new line 2) when the Str empties
% L is the line on who I append every character

% function that writes the whole list
write_list([]).
write_list([Head|Tail]):-
	write(Head),
	write_list(Tail).

% create a line that moves forward
forward_create(_,[],[],_,_,_).
forward_create([],[],[],_,_,_).
forward_create([], WRemains, HRemains, Pattern, Width, L) :-
  forward_create(Pattern, WRemains, HRemains, Pattern, Width, L).
forward_create(Str, [], [_ | HR], Pattern, Width, L) :-
  write_list(L),nl,
  backward_create(Str, Width, HR, Pattern, Width, []).
forward_create([Char | Str], [_ | WRemains], HRemains, Pattern, Width, L) :-
  append(L, [Char], NewL),
  forward_create(Str, WRemains, HRemains, Pattern, Width, NewL).

% create a line that moves backward
backward_create(_,[],[],_,_,_).
backward_create([],[],[],_,_,_).
backward_create([], WRemains, HRemains, Pattern, Width, L) :-
  backward_create(Pattern, WRemains, HRemains, Pattern, Width, L).
backward_create(Str, [], [_ | HR], Pattern, Width, L) :-
  reverse(L, NewL),
  write_list(NewL),nl,
  forward_create(Str, Width, HR, Pattern, Width, []).
backward_create([Char | Str], [_ | WRemains], HRemains, Pattern, Width, L) :-
  append(L, [Char], NewL),
  backward_create(Str, WRemains, HRemains, Pattern, Width, NewL).

% disnake
disnake(Pattern, Width, Height) :-
	forward_create(Pattern, Width, Height, Pattern, Width, []),nl.
