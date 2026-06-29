%total number of genes, repetitions are tagged differently.
#const tag=6.
#const t=2.


gene_labels(I;-I) :- I = 1..tag.


% exogenous actions.
action(transposition(I,J,K)) :- gene_labels(K), gene_labels(J), gene_labels(I).
action(transinversion(I,J,K)) :- gene_labels(K), gene_labels(J), gene_labels(I).
action(inversion(I,J)) :- gene_labels(J), gene_labels(I).
action(wait).
{occurs(A,T) : action(A)}=1 :- T = 0..t-1.


%direct effects of actions.

%--------------------transposition
{holds(gene_arr(J1,K),T+1); holds(gene_arr(K1,I),T+1); holds(gene_arr(I1,J),T+1)}=3 :- occurs(transposition(I,J,K),T), holds(gene_arr(I1,I),T), holds(gene_arr(J1,J),T), holds(gene_arr(K1,K),T), T = 0..t-1.

{-holds(gene_arr(I1,I),T+1); -holds(gene_arr(J1,J),T+1); -holds(gene_arr(K1,K),T+1)}=3 :- occurs(transposition(I,J,K),T), holds(gene_arr(I1,I),T), holds(gene_arr(J1,J),T), holds(gene_arr(K1,K),T), T = 0..t-1.

%--------------------inversion
{holds(gene_arr(I1,-J1),T+1); holds(gene_arr(-I,J),T+1)}=2 :- occurs(inversion(I,J),T), holds(gene_arr(I1,I),T), holds(gene_arr(J1,J),T), T = 0..t-1.

-holds(gene_arr(H,H1),T+1) :- occurs(inversion(I,J),T), in_between(I2,H,J,T), holds(gene_arr(I1,I),T),holds(gene_arr(I2,I1),T), holds(gene_arr(H,H1),T), T = 0..t-1.

holds(gene_arr(-H1,-H),T+1) :- occurs(inversion(I,J),T), in_between(I1,H,J1,T), holds(gene_arr(J1,J),T), holds(gene_arr(I1,I),T), holds(gene_arr(H,H1),T), T = 0..t-1.

%--------------------transinversion
{holds(gene_arr(-I,K),T+1); holds(gene_arr(K1,-J1),T+1); holds(gene_arr(I1,J),T+1)}=3 :- occurs(transinversion(I,J,K),T), holds(gene_arr(I1,I),T), holds(gene_arr(J1,J),T), holds(gene_arr(K1,K),T), T = 0..t-1.

{-holds(gene_arr(K1,K),T+1); -holds(gene_arr(J1,J),T+1); -holds(gene_arr(I1,I),T+1)}=3 :- occurs(transinversion(I,J,K),T), holds(gene_arr(I1,I),T), holds(gene_arr(J1,J),T), holds(gene_arr(K1,K),T), T = 0..t-1.

-holds(gene_arr(H,H1),T+1) :- occurs(transinversion(I,J,K),T), in_between(I2,H,J,T), holds(gene_arr(I1,I),T),holds(gene_arr(I2,I1),T), holds(gene_arr(H,H1),T), T = 0..t-1.

holds(gene_arr(-H1,-H),T+1) :- occurs(transinversion(I,J,K),T), in_between(I1,H,J1,T), holds(gene_arr(J1,J),T), holds(gene_arr(I1,I),T), holds(gene_arr(H,H1),T), T = 0..t-1.


%ramifications of actions --not sure about this part.

b_d(C,T) :- C=#count{J,J1 :  not holds(gene_arr(J,J1),T), final(gene_arr(J,J1))},  T = 0..t.

in_between(I,K,J,T) :- holds(gene_arr(I,K),T), holds(gene_arr(J,_),T), not holds(gene_arr(I,J),T), T = 0..t.
in_between(I,K,J,T) :- in_between(I,H,J,T), holds(gene_arr(H,K),T), J!=K, T = 0..t.

safe_2(I,J,T) :- holds(gene_arr(I1,I),T), holds(gene_arr(J1,J),T), not final(gene_arr(I1,I)), not final(gene_arr(J1,J)), T = 0..t-1.
safe_3(I,J,K,T) :- holds(gene_arr(I1,I),T), holds(gene_arr(J1,J),T), holds(gene_arr(K1,K),T), not final(gene_arr(K1,K)), not final(gene_arr(I1,I)), not final(gene_arr(J1,J)), T = 0..t-1.

%preconditions of actions.

:- occurs(transposition(I,J,K),T), in_between(I1,K,J0,T), holds(gene_arr(I1,I),T), holds(gene_arr(J,J0),T), T = 0..t-1.
:- occurs(transinversion(I,J,K),T), in_between(I1,K,J0,T), holds(gene_arr(I1,I),T), holds(gene_arr(J,J0),T), T = 0..t-1. 
:- occurs(transposition(I,J,K),T), not holds(gene_arr(J,_),T), not holds(gene_arr(I,_),T), not holds(gene_arr(K,_),T), T = 0..t-1.
:- occurs(transinversion(I,J,K),T), not holds(gene_arr(J,_),T), not holds(gene_arr(I,_),T), not holds(gene_arr(K,_),T), T = 0..t-1.
:- occurs(inversion(I,J),T), not holds(gene_arr(J,_),T), not holds(gene_arr(I,_),T), T = 0..t-1.
:- holds(gene_arr(I,_),T), holds(gene_arr(-I,_),T), gene_labels(I), T = 0..t-1.
:- not holds(gene_arr(I,_),T), not holds(gene_arr(-I,_),T), gene_labels(I), T = 0..t-1.


%safe atoms dramatically decreases memory usage and following conditions
:- not safe_2(I,J,T), occurs(inversion(I,J),T), T = 0..t-1.
:- not safe_3(I,J,K,T), occurs(transposition(I,J,K),T), T = 0..t-1.
:- not safe_3(I,J,K,T), occurs(transinversion(I,J,K),T), T = 0..t-1.


%postconditions of actions --not sure about this part.

:- not occurs(wait,T), b_d(C1,T), b_d(C2,T+1), C1<C2, T = 0..t-1.


%common sense law of inertia.

holds(gene_arr(I1,I),T+1) :- not -holds(gene_arr(I1,I),T+1), holds(gene_arr(I1,I),T), T = 0..t-1.
-holds(gene_arr(I1,I),T+1) :- not holds(gene_arr(I1,I),T+1), -holds(gene_arr(I1,I),T), T = 0..t-1.


% initial values of fluents

init(gene_arr(1,2); gene_arr(2,5); gene_arr(5,6);  gene_arr(6,4); gene_arr(4,3); gene_arr(3,1)).
holds(G,0) :- init(G).
%-holds(gene_arr(I1,I),0) :- not holds(gene_arr(I1,I),0), gene_labels(I), gene_labels(I1).


%goal

final(gene_arr(-2,-1); gene_arr(-1,5); gene_arr(5,6);  gene_arr(6,4); gene_arr(4,3); gene_arr(3,-2)).

goal(T) :-  {holds(G,T) :final(G)}=tag, T = 0..t.
success :- goal(T).
:- not success.

%alternatively we can define the goal with breakpoint distance
%goal(T) :- b_d(0,T), T = 0..t.
%success :- goal(T).
%:- not success.

%#maximize{T : occurs(wait,T)}.

#show holds/2.
#show occurs/2.
#show b_d/2.