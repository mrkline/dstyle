import production;
import grammardefinition;

import std.algorithm;
import std.stdio;
import std.exception;

@safe:

struct Grammar {

	void addProduction(ref const Production prod, ref const GrammarDefinition reducesTo)
	{
		enforce(reducesTo.type == ElementType.NONTERM, "A production must reduce to a nonterminal.");

		if (!(reducesTo in productionMap)) {
			productionMap[reducesTo] ~= prod;
			return;
		}

		enforce(!canFind(productionMap[reducesTo], prod), "The production has already been added.");

		productionMap[reducesTo] ~= prod;
	}

	const(Production[]) productionsThatReduceTo(ref in GrammarDefinition to) const
	{
		auto ptr = to in productionMap;
		if (ptr != null)
			return *ptr;
		else
			return [];
	}

	@property const(Production[][GrammarDefinition]) productions() const { return productionMap; }

private:
	Production[][GrammarDefinition] productionMap;
}

@trusted:

unittest
{
	writeln("Beginning grammar test");

	GrammarDefinition gd1 = GrammarDefinition(ElementType.NONTERM, 3, 5);
	GrammarDefinition gd2 = GrammarDefinition(ElementType.NONTERM, 4, 3);
	GrammarDefinition gd3 = GrammarDefinition(ElementType.TERM, 3, 1);
	GrammarDefinition gd4 = GrammarDefinition(ElementType.TERM, 2, 1);

	GrammarDefinition reducesTo = GrammarDefinition(ElementType.NONTERM, 42, 1);

	Production prod1 = Production([gd1, gd2, gd3], null);
	Production prod2 = Production([gd1, gd2, gd4], null);

	Grammar gram;

	gram.addProduction(prod1, reducesTo);
	gram.addProduction(prod2, reducesTo);

	assert(gram.productions.length == 1);

	auto prods = gram.productionsThatReduceTo(reducesTo);

	assert(prods.length == 2);
	assert(canFind(prods, prod1));
	assert(canFind(prods, prod2));
}


unittest
{
	GrammarDefinition gd1 = GrammarDefinition(ElementType.NONTERM, 3, 5);
	GrammarDefinition gd2 = GrammarDefinition(ElementType.NONTERM, 4, 3);
	GrammarDefinition gd3 = GrammarDefinition(ElementType.TERM, 3, 1);

	GrammarDefinition reducesTo = GrammarDefinition(ElementType.NONTERM, 42, 1);

	Production prod1 = Production([gd1, gd2, gd3], null);

	Grammar gram;

	gram.addProduction(prod1, reducesTo);

	// Assert that we don't allow duplicates
	assertThrown(gram.addProduction(prod1, reducesTo));
}

unittest
{
	GrammarDefinition gd1 = GrammarDefinition(ElementType.NONTERM, 3, 5);
	GrammarDefinition gd2 = GrammarDefinition(ElementType.NONTERM, 4, 3);
	GrammarDefinition gd3 = GrammarDefinition(ElementType.TERM, 3, 1);

	GrammarDefinition reducesTo = GrammarDefinition(ElementType.TERM, 42, 1);

	Production prod = Production([gd1, gd2, gd3], null);

	Grammar gram;

	assertThrown(gram.addProduction(prod, reducesTo));
}
