import grammartreenode;
import grammardefinition;
import grammar;
import production;

import std.algorithm;
import std.exception;
import std.stdio;

@safe:

/**
 * \brief Takes a parse stack from a shift-reduce parser
 *        and reduces as much of the top as possible to a terminal
 *
 * To do this, we'll take our grammar and use it to build a graph,
 * then follow that graph to the furthest leaf.
 */
struct Reducer {

	@trusted: // .keys is apparently a system function?
	void build(ref in Grammar grammar)
	{
		trees.clear();

		foreach (reducesTo; grammar.productions.keys) {
			foreach (production; grammar.productions[reducesTo]) {
				// Keep track of our current node as we move backwards
				// through the elements of the production
				GrammarTreeNode* currentNode;

				// If there is not an element in trees for the last item in production, create it.
				auto last = production.elements[$-1];
				auto matchingTreeNode = last in trees;
				if (matchingTreeNode == null) {
					currentNode = new GrammarTreeNode();
					trees[last] = currentNode;
				}
				else {
					currentNode = *matchingTreeNode;
				}

				for (long i = production.elements.length - 2; i > 0; --i) {
					// Add nodes going backwards to the start of the production.
					currentNode = currentNode.addChildAsNeeded(production.elements[i]);
				}

				// If the current node already has a reduction, we have an ambiguous grammar.
				enforce(currentNode.reduction == null, "The provided grammar is ambiguous");

				// At the end of the chain, set the reduction
				currentNode.reduction = &reducesTo;
			}
		}
	}

private:
	GrammarTreeNode*[GrammarDefinition] trees;
}

@trusted:

unittest
{
	writeln("Beginning reducer tests");
	GrammarDefinition gd1 = GrammarDefinition(ElementType.NONTERM, 3, 5);
	GrammarDefinition gd2 = GrammarDefinition(ElementType.NONTERM, 4, 3);
	GrammarDefinition gd3 = GrammarDefinition(ElementType.TERM, 3, 1);

	GrammarDefinition reduction1 = GrammarDefinition(ElementType.NONTERM, 42, 1);
	GrammarDefinition reduction2 = GrammarDefinition(ElementType.NONTERM, 43, 1);

	Production prod1 = Production([gd1, gd2, gd3], null);

	Grammar gram;

	gram.addProduction(prod1, reduction1);
	gram.addProduction(prod1, reduction2);

	Reducer red;

	assertThrown(red.build(gram));
}
