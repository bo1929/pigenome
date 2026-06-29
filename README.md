# Pigenome

A **Picat** planning approach to the **genome rearrangement problem**, with
supporting **Answer Set Programming (ASP)** encodings.

Given an initial signed permutation of genes and a target signed permutation,
the goal is to find a shortest sequence of rearrangement operations
(inversions, transpositions and transinversions) that transforms the initial
genome into the target genome.

This repository contains the final, consolidated project: Picat solver,
instance generator, ASP encodings, and the research reports.

---

## Table of Contents

- [Background](#background)
- [Repository Structure](#repository-structure)
- [Quick Start](#quick-start)
  - [Picat](#picat)
  - [ASP (Clingo)](#asp-clingo)
- [Generating New Instances](#generating-new-instances)
- [Documentation](#documentation)
- [Requirements](#requirements)
- [License](#license)

---

## Background

Genome rearrangements are large-scale mutations that change the order and
orientation of genes on a chromosome. The three classic operations modelled
here are:

- **Inversion** – reverses a contiguous segment and flips the sign of each
gene in the segment.
- **Transposition** – cuts out a contiguous segment and re-inserts it
elsewhere.
- **Transinversion** – a transposition where the moved segment is also
inverted.

The Picat implementation uses the built-in `planner` module and a greedy
heuristic based on **breakpoint distance**: an action is allowed only if it
strictly reduces the number of breakpoint differences with the target genome.

The `asp/` directory contains the earlier ASP formulations, kept for reference
and comparison.

---

## Repository Structure

```text
pigenome/
├── docs/                       # Research reports
│   ├── proposal.pdf
│   ├── asp-baseline.pdf
│   ├── incremental-asp.pdf
│   └── final-report.pdf
├── picat/                      # Picat programs
│   ├── small.pi                # 5-gene toy example
│   └── medium.pi               # Larger generated instance
├── asp/                        # Supporting ASP encodings for clingo
│   ├── encoding.lp             # Baseline ASP encoding
│   ├── nonincremental.lp       # Revised non-incremental encoding
│   ├── incremental.lp          # Incremental step/check program
│   └── control.lp              # Python control script for incremental solving
├── scripts/
│   └── generate_instance.py    # Generate a Picat instance from initial/final genomes
├── README.md
├── LICENSE
└── .gitignore
```

---

## Quick Start

### Picat

Run the small example directly with the Picat interpreter:

```bash
picat picat/small.pi
```

The program uses Picat's `best_plan/2` predicate to search for an optimal
plan from the hard-coded initial genome to the target genome.

### ASP (Clingo)

Run the baseline ASP encoding:

```bash
clingo asp/encoding.lp
```

Run the non-incremental encoding:

```bash
clingo asp/nonincremental.lp
```

Run the incremental encoding (the control script drives the incremental
search):

```bash
clingo asp/control.lp asp/incremental.lp
```

> The ASP encodings expect a fixed plan horizon (`#const t=...`) and an
> initial/final genome encoded inside the `.lp` file. Edit those constants to
> try different instances.

---

## Generating New Instances

The Python helper `scripts/generate_instance.py` writes a complete Picat
program for arbitrary signed permutations.

```bash
python scripts/generate_instance.py \
  --initial "{1,2,3,4,5}" \
  --final "{1,-3,-2,4,5}" \
  --length 5 \
  --output my_instance.pi

picat my_instance.pi
```

The script enumerates all valid inversion and transposition actions, adds
safety and breakpoint-distance constraints, and emits a self-contained
Picat file.

---

## Documentation

| File | Description |
|------|-------------|
| `docs/proposal.pdf` | Research proposal |
| `docs/asp-baseline.pdf` | Baseline ASP formulation of genome rearrangements as planning |
| `docs/incremental-asp.pdf` | Incremental ASP solution and performance improvements |
| `docs/final-report.pdf` | Final report including the Picat implementation and test results |

---

## Requirements

- [Picat](http://picat-lang.org/)
- [Clingo](https://potassco.org/clingo/) 5.x, for the ASP encodings
- Python 3.6+, for `scripts/generate_instance.py`

---

## License

This project is released under the MIT License. See [LICENSE](LICENSE) for
details.
