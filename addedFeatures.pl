% pokazuje (co najwyżej) N pierwszych węzłów grafu stanów
show_nodes(_, _, 0, 0) :- !.		 % ! -> w razie nawrotu koniec

show_nodes([], _, N, N).

show_nodes([node(State, Action,Parent, Cost, Score)|Queue], ClosedSet, N, Rejected):-
	is_member(node(State, _, _, _, _), ClosedSet), ! ,
	show_nodes(Queue, ClosedSet, N, Rejected).

show_nodes([X|Queue], ClosedSet, N, Rejected):-
	write(X), nl,
	NewN is N - 1,
	show_nodes(Queue, ClosedSet, NewN, Rejected).

% sprawdza czy dany element należy do listy (odpowiednik procedury wbudowanej "member")
is_member(X, [X|_]).

is_member(X, [_|List]) :-
	is_member(X, List).

% wrapper dla get_index_list
get_input_indexes(N, IndexList) :-
	write("Wpisz indeksy:"), nl,
	get_index_list(0, N, IndexList).

% pobiera listę indeksów od użytkownika
get_index_list(N, N, []) :- !.			% ! -> w razie nawrotu koniec (niepowodzenie)

get_index_list(CurrN, N, [X|IndexList]) :-
	NextCurrN is CurrN+1,
	read(X),
	get_index_list(NextCurrN, N, IndexList).

% pobiera indeks z listy indeksów (wykorzystanie napisanej wcześniej procedury is_member)
get_index(Index, IndexList) :-
	is_member(Index, IndexList).

% wrapper dla get_node_by_index_proc
	get_node_by_index(OutNode, Queue, ClosedSet, Index) :-
		get_node_by_index_proc(OutNode, _, Queue, ClosedSet, Index).

% procedura wczytująca do OutNode węzeł na zadanej przez indeks pozycji (nie wliczając węzłów nalezących do ClosedSet)
get_node_by_index_proc(OutNode, node(State, Action,Parent, Cost, Score), [node(State, Action,Parent, Cost, Score) |Queue], ClosedSet, Index) :-
	is_member(node(State, _ ,_  , _ , _ ) , ClosedSet),   !,
	get_node_by_index_proc(OutNode, _, Queue, ClosedSet, Index).

get_node_by_index_proc(Node, Node, [Node|Queue], ClosedSet, 1).

get_node_by_index_proc(OutNode, _, [_|Queue], ClosedSet, Index) :-
	NewCounter is Index-1,
	get_node_by_index_proc(OutNode, _, Queue, ClosedSet, NewCounter).

% zmodyfikowana procedura fetch
new_fetch(Node, Queue, ClosedSet, N) :-
	show_nodes(Queue, ClosedSet, N, Rejected),
	EligibleN is N-Rejected,
	get_input_indexes(EligibleN, IndexList),
	get_index(Index, IndexList),
	get_node_by_index(Node, Queue, ClosedSet, Index).
