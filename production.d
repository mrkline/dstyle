import grammardefinition;
import grammarelement;
import astnode;

import std.stdio;

@safe:

struct Production {

	alias ASTNode delegate(GrammarElement[]) SDTCallback;

	immutable GrammarDefinition[] elements;

	immutable SDTCallback translator;

	this(GrammarDefinition[] elems, SDTCallback trans)
	{
		elements = elems.dup;
		translator = trans;
	}

	bool opEquals(in Production o)
	{
		return elements == o.elements
			&& translator == o.translator;
	}
}

@trusted:

unittest
{
	writeln("Beginning production test");
	GrammarDefinition gd1 = GrammarDefinition(ElementType.NONTERM, 3, 5);
	GrammarDefinition gd2 = GrammarDefinition(ElementType.NONTERM, 4, 3);
	GrammarDefinition gd3 = GrammarDefinition(ElementType.TERM, 3, 1);

	Production prod1 = Production([gd1, gd2, gd3], null);
	Production prod2 = Production([gd1, gd2, gd3], null);

	assert(prod1 == prod2);
}
