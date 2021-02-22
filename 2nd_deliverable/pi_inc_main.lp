#program base.
init(gene_arr(1,5); gene_arr(-4,-3); gene_arr(6,-2);  gene_arr(5,-4); gene_arr(-3,6); gene_arr(-2,1)).
holds(G,0) :- init(G).

final(gene_arr(-5,-2); gene_arr(3,4); gene_arr(-2,3);  gene_arr(4,6); gene_arr(6,-1); gene_arr(-1,-5)).
b_d(C,0) :- C=#count{J,J1 :  not holds(gene_arr(J,J1),0), final(gene_arr(J,J1))}.
in_between(I,K,J,1) :- holds(gene_arr(I,K),0), holds(gene_arr(J,_),0), not holds(gene_arr(I,J),0).
in_between(I,K,J,1) :- in_between(I,H,J,1), holds(gene_arr(H,K),0), J!=K.

safe_2(I,J,1) :- holds(gene_arr(I1,I),0), holds(gene_arr(I2,I1),0), in_between(I2,H,J,1),  holds(gene_arr(H,H0),0),  not final(gene_arr(H,H0)).
safe_3(I,J,K,1) :- holds(gene_arr(I1,I),0), holds(gene_arr(J1,J),0), holds(gene_arr(K1,K),0), not final(gene_arr(K1,K)), not final(gene_arr(I1,I)), not final(gene_arr(J1,J)).


#const tag=6.
gene_labels(I;-I) :- I = 1..tag.
action(transposition(I,J,K)) :- gene_labels(K), gene_labels(J), gene_labels(I).
action(inversion(I,J)) :- gene_labels(J), gene_labels(I).
action(wait).

#program check (t).
:- not goal(t), query(t).
:- not occurs(wait,t), b_d(C1,t), b_d(C2,t-1), C1>=C2, query(t).

#program step(t).

{occurs(A,t) : action(A)}=1.


%direct effects of actions.

%--------------------transposition
holds(gene_arr(I1,J),t) :- occurs(transposition(I,J,K),t), holds(gene_arr(I1,I),t-1).
holds(gene_arr(J1,K),t) :- occurs(transposition(I,J,K),t), holds(gene_arr(J1,J),t-1).
holds(gene_arr(K1,I),t) :- occurs(transposition(I,J,K),t), holds(gene_arr(K1,K),t-1).



%--------------------inversion
holds(gene_arr(-I,J),t) :- occurs(inversion(I,J),t).
holds(gene_arr(I1,-J1),t) :- occurs(inversion(I,J),t), holds(gene_arr(I1,I),t-1), holds(gene_arr(J1,J),t-1).

holds(gene_arr(-H1,-H),t) :- occurs(inversion(I,J),t), in_between(I1,H,J1,t), holds(gene_arr(J1,J),t-1), holds(gene_arr(I1,I),t-1), holds(gene_arr(H,H1),t-1).


%ramifications of actions --not sure about this part.

b_d(C,t) :- C=#count{J,J1 :  not holds(gene_arr(J,J1),t), final(gene_arr(J,J1))}.

in_between(I,K,J,t) :- holds(gene_arr(I,K),t-1), holds(gene_arr(J,_),t-1), not holds(gene_arr(I,J),t-1).
in_between(I,K,J,t) :- in_between(I,H,J,t), holds(gene_arr(H,K),t-1), J!=K.

safe_2(I,J,t) :- holds(gene_arr(I1,I),t-1), holds(gene_arr(I2,I1),t-1), in_between(I2,H,J,t),  holds(gene_arr(H,H0),t-1),  not final(gene_arr(H,H0)).
safe_3(I,J,K,t) :- holds(gene_arr(I1,I),t-1), holds(gene_arr(J1,J),t-1), holds(gene_arr(K1,K),t-1), not final(gene_arr(K1,K)), not final(gene_arr(I1,I)), not final(gene_arr(J1,J)).

%preconditions of actions.

:- occurs(transposition(I,J,K),t), in_between(I1,K,J0,t), holds(gene_arr(I1,I),t-1), holds(gene_arr(J,J0),t-1).
:- holds(gene_arr(I,_),t), holds(gene_arr(-I,_),t), I = 1..tag.

:- not holds(gene_arr(I,_),t), not holds(gene_arr(-I,_),t), I = 1..tag.


%safe atoms dramatically decreases memory usage and following conditions
:- not safe_2(I,J,t), occurs(inversion(I,J),t).
:- not safe_3(I,J,K,t), occurs(transposition(I,J,K),t).


%state constraints

:- holds(gene_arr(I,J),t), holds(gene_arr(I,K),t), J!=K.
:- holds(gene_arr(J,I),t), holds(gene_arr(K,I),t), J!=K.
:- holds(gene_arr(I,J),t), I=J.
:- not occurs(wait,t), b_d(C1,t), b_d(C2,t-1), C1>=C2.


%common sense law of inertia.

{holds(gene_arr(I1,I),t)} :- holds(gene_arr(I1,I),t-1).

goal(t) :- b_d(0,t).

%greedy
%#minimize{C : b_d(C,t)}.

#show occurs/2.
#show b_d/2.