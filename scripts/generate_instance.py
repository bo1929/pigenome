#!/usr/bin/env python3
"""Generate a Picat genome-rearrangement instance.

Given an initial signed permutation, a final signed permutation and the
genome length, this script writes a self-contained Picat program that uses
the Picat planner module to search for an optimal rearrangement plan.

Example:
    python scripts/generate_instance.py \
        --initial "{1,2,3,4,5}" \
        --final "{1,-3,-2,4,5}" \
        --length 5 \
        --output my_instance.pi

    picat my_instance.pi
"""

import argparse


COMMON_PREDICATES = """import math.
import planner.

main =>
    InitGen = __INITIAL__,
    best_plan(InitGen, Plan),
    foreach (Action in Plan)
        println(Action)
    end.

final(Gen) => Gen = normalize(__FINAL__).

inversion(G,I,J) = Gnew, J>I => Gnew = slice(G,1,I-1) ++ {-X : X in reverse(slice(G,I,J-1))} ++ slice(G,J).
inversion(G,I,J) = Gnew, I>J => Gnew = {-X : X in reverse(slice(G,I))} ++ slice(G,J+1,I-1) ++ {-X : X in reverse(slice(G,1,J))}.

same_gen(G1,G2), compare_terms(G1,G2) == 0 => true.
same_gen(G1,G2), compare_terms(G1,{-X : X in reverse(G2)}) == 0 => true.
same_gen(G1,G2), first(G1)!=first(G2), len(G1)==len(G2) => same_gen({first(G1)} ++ slice(G1,1,len(G1)-1),G2).

transposition(G,I,J,K) = Gnew, J>I, K<I => Gnew = slice(G,1,K-1) ++ slice(G,I,J-1) ++ slice(G,K,I-1) ++ slice(G,J).
transposition(G,I,J,K) = Gnew, J>I, K>J => Gnew = slice(G,1,I-1) ++ slice(G,J,K-1) ++ slice(G,I,J-1) ++ slice(G,K).
transposition(G,I,J,K) = Gnew, I>J, K<I, K>J => Gnew = slice(G,J,K-1) ++ slice(G,I) ++ slice(G,1,J-1) ++ slice(G,K,I-1).

b_dist(G1,G2) = Bd, len(G1)==len(G2) => Bd = sum([1 : I in 1..len(G1)-1, not (G1[I]==G2[I], G1[I+1]==G2[I+1])]).

circulate(G) = Gn => Gn = {last(G)}++G++{first(G)}.

safe_btw(G1,G2,I,J), len(G1)==len(G2) => (len({K : K in I-1..J-1, G1[K]==G2[K+1]})==0).
safe(G1,G2,I,J,K), len(G1)==len(G2) => not ((G1[I-1]==G2[I-1], G1[I]==G2[I]); (G1[J-1]==G2[J-1], G1[J]==G2[J]); (G1[K-1]==G2[K-1], G1[K]==G2[K])).

indexes(Gen) = X => X = [J : J in 1..len(Gen)].

normalize(G) = Gn => Gn=G,
                     while( first(Gn) != 1 , first(Gn) != -1)
                        Gn := {last(Gn)} ++ slice(Gn,1,len(Gn)-1),
                        if first(Gn) == -1 then
                            Gn := {(-1)*X : X in reverse(Gn)},
                            Gn := Gn
                        end
                     end.

"""


def generate(initial, final, length):
    """Return the Picat program text for the given instance."""
    program = COMMON_PREDICATES.replace("__INITIAL__", initial).replace("__FINAL__", final)

    # Inversions: every ordered pair of distinct indices.
    for i in range(1, length + 1):
        for j in range(1, length + 1):
            if i == j:
                continue
            program += (
                f"action(Genome1,Genome2,Action,ActionCost) ?=>")
            program += (
                f"\n    Action=inv{i}{j},\n"
                f"    ActionCost = 1,\n"
                f"    final(Gen),\n"
                f"    safe_btw(circulate(Genome1),circulate(Gen),{i + 1},{j + 1}),\n"
                f"    Genome2 = normalize(inversion(Genome1,{i},{j})),\n"
                f"    b_dist(circulate(Genome2),circulate(Gen)) < b_dist(circulate(Genome1),circulate(Gen)).\n\n"
            )

    # Transpositions: only the geometrically valid triples.
    for i in range(1, length + 1):
        for j in range(1, length + 1):
            for k in range(1, length + 1):
                if (i < j and k < i) or (i < j and k > j) or (i > j and k < i and k > j):
                    program += (
                        f"action(Genome1,Genome2,Action,ActionCost) ?=>")
                    program += (
                        f"\n    Action=tp{i}{j}{k},\n"
                        f"    ActionCost = 1,\n"
                        f"    final(Gen),\n"
                        f"    safe(circulate(Genome1),circulate(Gen),{i + 1},{j + 1},{k + 1}),\n"
                        f"    Genome2 = normalize(transposition(Genome1,{i},{j},{k})),\n"
                        f"    b_dist(circulate(Genome2),circulate(Gen)) < b_dist(circulate(Genome1),circulate(Gen)).\n\n"
                    )

    return program


def main():
    parser = argparse.ArgumentParser(
        description="Generate a Picat genome-rearrangement instance."
    )
    parser.add_argument(
        "--initial", "-i", required=True,
        help="Initial genome as a Picat list, e.g. '{1,2,3,4,5}'"
    )
    parser.add_argument(
        "--final", "-f", required=True,
        help="Target genome as a Picat list, e.g. '{1,-3,-2,4,5}'"
    )
    parser.add_argument(
        "--length", "-n", type=int, required=True,
        help="Number of genes in the permutation"
    )
    parser.add_argument(
        "--output", "-o", default="genarr_instance.pi",
        help="Output Picat file (default: genarr_instance.pi)"
    )
    args = parser.parse_args()

    program = generate(args.initial, args.final, args.length)
    with open(args.output, "w") as f:
        f.write(program)
    print(f"Wrote Picat instance to {args.output}")


if __name__ == "__main__":
    main()
