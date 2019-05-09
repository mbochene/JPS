% N-argument zadany przez użytkownika

start_A_star( InitState, PathCost, N, StepLimit) :-
	score(InitState, 0, 0, InitCost, InitScore) ,
	search_A_star( [node(InitState, nil, nil, InitCost , InitScore ) ], [ ], N, 1, StepLimit, PathCost).


search_A_star(Queue, ClosedSet, N, StepCounter, StepLimit, PathCost) :-
	StepCounter < StepLimit, ! ,
	write("Numer kroku: "),
	write(StepCounter), nl,
	new_fetch(Node, Queue, ClosedSet, N, NewQueue),
	NewStepCounter is StepCounter + 1,
	continue(Node, NewQueue, ClosedSet, N, NewStepCounter, StepLimit, PathCost).

search_A_star(Queue, ClosedSet, N, StepCounter, StepLimit, PathCost) :-
	write("Numer kroku: "),
	write(StepCounter), nl,
	write("Przekroczono limit kroków. Zwiekszyc limit? (t/n)"), nl,
	read('t'), !,
	NewLimit is StepLimit + 1,
	new_fetch(Node, Queue, ClosedSet, N, NewQueue),
	NewStepCounter is StepCounter + 1,
	continue(Node, NewQueue, ClosedSet, N, NewStepCounter, NewLimit, PathCost).

continue(node(State, Action, Parent, Cost, _ ) , _  ,  ClosedSet, _, StepCounter, _, path_cost(Path, Cost) ) :-
	goal( State), ! ,
	build_path(node(Parent, _ ,_ , _ , _ ) , ClosedSet, [Action/State], Path).

continue(Node, Queue, ClosedSet, N, NewStepCounter, StepLimit, Path)   :-
	expand(Node, NewNodes),
	insert_new_nodes(NewNodes, Queue, NewQueue),
	search_A_star(NewQueue, [Node | ClosedSet ], N, NewStepCounter, StepLimit, Path).

expand(node(State, _ ,_ , Cost, _ ), NewNodes)  :-
	new_findall(State, Cost, NewNodes).

score(State, ParentCost, StepCost, Cost, FScore)  :-
	Cost is ParentCost + StepCost ,
	hScore(State, HScore),
	FScore is Cost + HScore .

insert_new_nodes( [ ], Queue, Queue) .

insert_new_nodes( [Node|RestNodes], Queue, NewQueue) :-
	insert_p_queue(Node, Queue, Queue1),
	insert_new_nodes(RestNodes, Queue1, NewQueue).

insert_p_queue(Node,  [ ], [Node] )      :-    ! .

insert_p_queue(node(State, Action, Parent, Cost, FScore),
		[node(State1, Action1, Parent1, Cost1, FScore1)|RestQueue],
			[node(State1, Action1, Parent1, Cost1, FScore1)|Rest1] )  :-

	FScore >= FScore1,  ! ,
	insert_p_queue(node(State, Action, Parent, Cost, FScore), RestQueue, Rest1).


insert_p_queue(node(State, Action, Parent, Cost, FScore),  Queue,
				[node(State, Action, Parent, Cost, FScore)|Queue]).


build_path(node(nil, _, _, _, _ ), _, Path, Path) :- !.

build_path(node(EndState, _ , _ , _, _ ), Nodes, PartialPath, Path)  :-
	del(Nodes, node(EndState, Action, Parent , _ , _  ), Nodes1),
	build_path(node(Parent,_ ,_ , _ , _ ) ,Nodes1, [Action/EndState|PartialPath], Path).

del([X|R],X,R).
del([Y|R],X,[Y|R1]) :-
	X\=Y,
	del(R,X,R1).

% procedura zastępująca findall
new_findall(State, Cost, _) :-
		succ(State, Action, StepCost, ChildState),
		score(ChildState, Cost, StepCost, NewCost, ChildScore),
        assert(new_find_all( node(ChildState, Action, State, NewCost, ChildScore) )), % umieszczenie całego node w bazie
        fail.

new_findall(_, _, NewNodes) :-				% w przypadku gdy nie ma już więcej węzłów do dodania, należy umieścić dodane poprzez assert węzły w liście
	assert(new_find_all( [] )),				% umieszczenie znaku poocniczego w bazie (osiągnięcie przez retract '[]' oznacza, że pobrano już wszystkie węzły)
    collect_new_nodes(NewNodes).

collect_new_nodes(List) :-
    retract(new_find_all(Node)), !,			% "powstrzymanie" retract przy nawrotach (związanych z odmową zwiększenia limitu kroków)
    collect_new_nodes_proc(Node, List).

collect_new_nodes_proc([], []).				% w przypadku pobrania "[]" przez retract należy skończyć rekursuję

collect_new_nodes_proc(Node, [Node|List]) :-
    collect_new_nodes(List).

% pokazuje (co najwyżej) N pierwszych węzłów grafu stanów
show_nodes(_, _, 0, 0) :- !.	% ! -> w razie nawrotu koniec (sytuacja, gdy N równe jest ilości węzłów nienależących do ClosedSet)

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
get_index_list(N, N, []) :- !.			% ! -> w razie nawrotu koniec (sytuacja, gdy dla wszystkich pobranych węzłów dalsza część algorytmu zakończy się niepowodzeniem)

get_index_list(CurrN, N, [X|IndexList]) :-
	NextCurrN is CurrN+1,
	read(X),
	get_index_list(NextCurrN, N, IndexList).

% pobiera indeks z listy indeksów (wykorzystanie napisanej wcześniej procedury is_member)
get_index(Index, IndexList) :-
	is_member(Index, IndexList).

% wrapper dla get_node_by_index_proc
get_node_by_index(OutNode, Queue, ClosedSet, Index, NewQueue) :-
	get_node_by_index_proc(OutNode, _, Queue, ClosedSet, Index, NewQueue).

% procedura wczytująca do OutNode węzeł na zadanej przez indeks pozycji (nie wliczając węzłów nalezących do ClosedSet)
get_node_by_index_proc(OutNode, node(State, Action,Parent, Cost, Score), [node(State, Action,Parent, Cost, Score) |Queue], ClosedSet, Index, 
	[node(State, Action,Parent, Cost, Score)|NewQueue]) :-
	is_member(node(State, _ ,_  , _ , _ ) , ClosedSet),   !,
	get_node_by_index_proc(OutNode, _, Queue, ClosedSet, Index, NewQueue).

get_node_by_index_proc(Node, Node, [Node|Queue], ClosedSet, 1, Queue).

get_node_by_index_proc(OutNode, _, [Node|Queue], ClosedSet, Index, [Node|NewQueue]) :-
	NewCounter is Index-1,
	get_node_by_index_proc(OutNode, _, Queue, ClosedSet, NewCounter, NewQueue).

% zmodyfikowana procedura fetch
new_fetch(Node, Queue, ClosedSet, N, NewQueue) :-
	show_nodes(Queue, ClosedSet, N, Rejected),
	EligibleN is N-Rejected,
	get_input_indexes(EligibleN, IndexList),
	get_index(Index, IndexList),
	get_node_by_index(Node, Queue, ClosedSet, Index, NewQueue).