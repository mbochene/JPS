% pokazuje (co najwyżej) N pierwszych węzłów grafu stanów
show_nodes(_, _, 0, 0) :- !.

show_nodes([], _, N, N).

show_nodes([X|R], ClosedSet, N, Rejected):-
	is_member(X, ClosedSet), ! ,
	show_nodes(R, ClosedSet, N, Rejected).

show_nodes([X|R], ClosedSet, N, Rejected):-
	write(X), nl,
	NewN is N - 1,
	show_nodes(R, ClosedSet, NewN, Rejected).

% sprawdza czy dany element należy do listy (odpowiednik procedury wbudowanej "member")
is_member(X, [X|_]).

is_member(X, [_|List]) :-
	is_member(X, List).

% wrapper dla get_index_list
get_input_indexes(N, IndexList) :-
	write("Wpisz indeksy:"), nl,
	get_index_list(0, N, IndexList).

% pobiera listę indeksów od użytkownika
get_index_list(N, N, []).

get_index_list(CurrN, N, [X|IndexList]) :-
	NextCurrN is CurrN+1,
	read(X),
	get_index_list(NextCurrN, N, IndexList).

% pobiera indeks z listy indeksów (wykorzystanie napisanej wcześniej procedury is_member)
get_index(Index, IndexList) :-
	is_member(Index, IndexList).

% zmodyfikowana procedura fetch
new_fetch(Node, Queue, ClosedSet, RestQueue, N) :-
	show_nodes(Queue, ClosedSet, N, Rejected),
	EligibleN is N-Rejected,
	get_input_indexes(EligibleN, IndexList),
	get_index(Index, IndexList),
	write(Index).
