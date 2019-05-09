goal([pos(0,3/1), pos(1,1/3), pos(2,2/3), pos(3,3/3), pos(4,1/2), pos(5,2/2), pos(6,3/2), pos(7,1/1), pos(8,2/1)]).

% procedura sprawdzająca czy płytka znajuje się na właściwym miejscu; kończy się powodzeniem, jeśli tak
isPosProper([pos(X,Y)|_], pos(X,Y)) :- !.

isPosProper([_|TilePositions], pos(X,Y)) :-
    isPosProper(TilePositions, pos(X,Y)).

hScore([], 0).

hScore([First|Rest], Score) :-
    goal(List),
    isPosProper(List, First), !,
    hScore(Rest, Score).

hScore([First|Rest], Score) :-
    hScore(Rest, RestScore),
    Score is RestScore + 1.

% procedura uzgadniająca drugi argument wywołania z wartością bezwzględną pierwszego argumentu
abs(X,X) :-
    X >=0, !.

abs(X, AbsX) :-
    AbsX is -X.

% procedura sprawdzająca czy dwa kafelki położone są bezpośrednio koło siebie
isAdjacent(X1/Y, X2/Y) :-
    DeltaX is X1-X2,
    abs(DeltaX, 1).

isAdjacent(X/Y1, X/Y2) :-
    DeltaY is Y1-Y2,
    abs(DeltaY, 1).

% procedura znajdująca "sąsiada" pustego pola i dokonująca zamiany
find_neighbour(EmptyPos, [pos(Neighbour, NPos)|TilePositions], NPos, [pos(Neighbour, EmptyPos)|TilePositions]) :-
    isAdjacent(EmptyPos, NPos).

find_neighbour(EmptyPos, [Tile|TilePositions], NewEmptyPos, [Tile|NewTilePositions]) :-
    find_neighbour(EmptyPos, TilePositions, NewEmptyPos, NewTilePositions).

% nowa procedura successor
succ( [ pos(0, EmptyPos)|TilePositions], (EmptyPos->NewEmptyPos), 1, [pos(0, NewEmptyPos)|NewTilePositions] ) :-
    find_neighbour(EmptyPos, TilePositions, NewEmptyPos, NewTilePositions).