#script (python) 

import clingo


def between_genes(self,x,my_models):
	return x

def safe_genes_3(prg,t,my_models):
	safe_3_rules = ""
	holds = [x.symbol for x in my_models if int(str(x.symbol.arguments[1])) == t-1 and str(x.name) == "holds" ]
	final = [x.symbol for x in prg.symbolic_atoms.by_signature("final", 1)]
	print(my_models,11)
	#print((holds))
	count = 0
	'''for i in holds:
		for j in holds:
			for k in holds:
				if i not in final and j not in final and k not in final:
					count = count +1
					#temp_r = clingo.Function("safe_3",[int(str(i.arguments[0].arguments[1])),int(str(j.arguments[0].arguments[1])),int(str(k.arguments[0].arguments[1])),t])
					#safe_3_rules.append(temp_r)
					safe_3_rules = safe_3_rules + "safe_3("+str(i.arguments[0].arguments[1])+","+(str(j.arguments[0].arguments[1]))+","+(str(k.arguments[0].arguments[1]))+","+str(t)+").\n"
	print((count))'''		
	return safe_3_rules
def get(val, default):
	return val if val != None else default

def main(prg):
	imin   = get(prg.get_const("imin"), clingo.Number(0))
	imax   = prg.get_const("imax")
	istop  = get(prg.get_const("istop"), clingo.String("SAT"))

	step, ret = 0, None
	while ((imax is None or step < imax.number) and
		   (step == 0 or step < imin.number or (
			  (istop.string == "SAT"     and not ret.satisfiable) or
			  (istop.string == "UNSAT"   and not ret.unsatisfiable) or 
			  (istop.string == "UNKNOWN" and not ret.unknown)))):
		parts = []
		parts.append(("check", [step]))
		if step > 0:
			prg.release_external(clingo.Function("query", [step-1]))
			
			'''prg.add("step", [step], safe3)'''
			parts.append(("step", [step]))
			#with prg.backend() as backend:
			#	for r in safe3:
			#		atm_r = backend.add_atom(r)
			#		backend.add_rule([atm_r])
			prg.cleanup()
		else:
			parts.append(("base", []))
		prg.ground(parts)
		prg.assign_external(clingo.Function("query", [step]), True)
		ret, step = prg.solve(), step+1
		prg.cleanup()


		
#end.

#program check(t).
#external query(t).