get_input_indexes(N, IndexList) :-
	write("Wpisz indeksy:"), nl,
	get_index_list(0, N, IndexList).

get_index_list(N, N, []).

get_index_list(CurrN, N, [X|IndexList]) :-
	NextCurrN is CurrN+1,
	read(X),
	get_index_list(NextCurrN, N, IndexList).




