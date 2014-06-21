import grammardefinition;
import grammarelement;
import astnode;

import std.exception;

@safe:

struct Production {

	alias ASTNode delegate(GrammarElement[]) SDTCallback;

	GrammarDefinition[] elements;

	GrammarDefinition reducesTo;

	SDTCallback translator;

	this(GrammarDefinition[] elems, GrammarDefinition to, SDTCallback trans)
	{
		enforce(elems.length > 0, "A production must have at least one element.");
		enforce(to.type == ElementType.Nonterm, "A production must reduce to a nonterminal.");

		elements = elems.dup;
		reducesTo = to;
		translator = trans;
	}
}

unittest
{
	auto gd1 = GrammarDefinition(ElementType.Nonterm, 3);
	auto gd2 = GrammarDefinition(ElementType.Nonterm, 4);
	auto gd3 = GrammarDefinition(ElementType.Term, 3);

	auto red1 = GrammarDefinition(ElementType.Nonterm, 5);

	auto prod1 = Production([gd1, gd2, gd3], red1, null);
	auto prod2 = Production([gd1, gd2, gd3], red1, null);

	assert(prod1 == prod2);
}
