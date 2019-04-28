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

%expand(node(State, _ ,_ , Cost, _ ), NewNodes)  :-
%	findall(node(ChildState, Action, State, NewCost, ChildScore) ,
%			(succ(State, Action, StepCost, ChildState), score(ChildState, Cost, StepCost, NewCost, ChildScore) ) ,
%											NewNodes).

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
