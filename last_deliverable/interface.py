
print("please enter the initial and the final genome in the format {1,...n} as a permutation of numbers 1 to n:")
rows = []
for i in range(0,2):
	print("please enter the values of", i+1, "gen: (right to left)")
	rows.append((input ("")))

if len(rows[0])!= len(rows[0]):
		print("insertion and deletion not implemented yet")
		exit()


print("please enter the values of length of the gen")
lenn = int((input ("")))

f= open("genarr_instance.pi","w+")

f.write("""import math. 
import planner.
main =>
	InitGen = """+rows[0]+""",
	best_plan(InitGen,Plan),
	foreach (Action in Plan)
		println(Action)
	end.

final(Gen)  => Gen =  normalize("""+rows[1]+""").

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
""")


for i in range(1,lenn+1):
	for j in range (1, lenn+1):
		if i != j:
			f.write(
"""action(Genome1,Genome2,Action,ActionCost) ?=>
	Action="""+"""inv"""+str(i)+str(j)+""",
	ActionCost = 1,
	final(Gen),
	safe_btw(circulate(Genome1),circulate(Gen),"""+str(i+1)+""","""+str(j+1)+"""),
	Genome2 = normalize(inversion(Genome1,"""+str(i)+""","""+str(j)+""")),
	b_dist(circulate(Genome2),circulate(Gen)) < b_dist(circulate(Genome1),circulate(Gen)).\n""")


for i in range(1,lenn+1):
	for j in range (1, lenn+1):
		for k in range (1, lenn+1):
			if (i < j and k < i) or (i < j and k>j) or (i>j and k <i and k>j):
				f.write("""
action(Genome1,Genome2,Action,ActionCost) ?=>
	Action=tp"""+str(i)+str(j)+str(k)+""",
	ActionCost = 1,
	final(Gen),
	safe(circulate(Genome1),circulate(Gen),"""+str(i+1)+""","""+str(j+1)+""","""+str(k+1)+"""),
	Genome2 = normalize(transposition(Genome1,"""+str(i)+""","""+str(j)+""","""+str(k)+""")),
	b_dist(circulate(Genome2),circulate(Gen)) < b_dist(circulate(Genome1),circulate(Gen)).\n""")
