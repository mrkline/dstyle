import grammartreenode;
import grammardefinition;
import grammarelement;
import production;

import std.algorithm;
import std.exception;

// TODO: Add logging

@safe:

/**
 * \brief Takes a parse stack from a shift-reduce parser
 *        and reduces as much of the top as possible to a terminal
 *
 * To do this, we'll take our grammar and use it to build a graph,
 * then follow that graph to the furthest leaf.
 */
struct Reducer {

	@disable this();

	this(in Production[] grammar)
	{

		foreach (production; grammar) {
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

			for (long i = production.elements.length - 2; i >= 0; --i) {
				// Add nodes going backwards to the start of the production.
				currentNode = currentNode.addChildAsNeeded(production.elements[i]);
			}

			// If the current node already has a reduction, we have an ambiguous grammar.
			enforce(currentNode.translator == null && currentNode.reduction == null,
				"The provided grammar is ambiguous");

			// At the end of the chain, set the reduction
			currentNode.translator = production.translator;
			currentNode.reduction = new GrammarDefinition;
			*currentNode.reduction = production.reducesTo;
		}
	}

	unittest
	{
		auto gd1 = GrammarDefinition(ElementType.Nonterm, 3);
		auto gd2 = GrammarDefinition(ElementType.Nonterm, 4);
		auto gd3 = GrammarDefinition(ElementType.Term, 3);

		auto reduction1 = GrammarDefinition(ElementType.Nonterm, 42);
		auto reduction2 = GrammarDefinition(ElementType.Nonterm, 43);

		auto prod1 = Production([gd1, gd2, gd3], reduction1, null);
		auto prod2 = Production([gd1, gd2, gd3], reduction2, null);

		// Should be ambiguous
		assertThrown(Reducer([prod1, prod2]));
	}

	struct ReductionResult {
		Production.SDTCallback translator;
		GrammarDefinition reducesTo;
		int elementsConsumed;
	}

	/**
	 * \brief Reduces a series of grammar elements to a new one.
	 * \param stack The current parse stack
	 * \returns ReductionResult.init if no reduction can be made.
	 *          If one can be made, a reslult contaitning the translator
	 *          that yields the reduction and the number of elements
	 *          consumed by it
	 *
	 * The elements on the stack are examined from back to front.
	 *
	 * We could call the translator and modify the stack ourselves,
	 * but we'll leave that work to the caller.
	 */
	ReductionResult reduce(S)(S[] stack) if (is(S == GrammarDefinition) || is(S == GrammarElement))
	{
		auto pop = {
			static if (is(S == GrammarDefinition))
				auto ret = stack[$-1];
			else
				auto ret = stack[$-1].def;
			stack = stack[0..$-1];
			return ret;
		};

		ReductionResult ret;
		int consumed;

		for (GrammarTreeNode** curr = pop() in trees; curr != null; curr = pop() in (*curr).edges) {
			++consumed;
			if ((*curr).reduction != null) {
				ret.translator = (*curr).translator;
				ret.reducesTo = *(*curr).reduction;
				ret.elementsConsumed = consumed;
			}
		}

		return ret;
	}

	unittest
	{
		auto foo = GrammarDefinition(ElementType.Term, 1);
		auto bar = GrammarDefinition(ElementType.Term, 2);
		auto baz = GrammarDefinition(ElementType.Term, 3);
		auto biz = GrammarDefinition(ElementType.Term, 4);

		auto foobar = GrammarDefinition(ElementType.Nonterm, 42);
		auto foobarbaz = GrammarDefinition(ElementType.Nonterm, 43);
		auto foobiz = GrammarDefinition(ElementType.Nonterm, 44);

		Production[] prods;
		prods ~= Production([foo, bar], foobar, null);
		prods ~= Production([foo, bar, baz], foobarbaz, null);
		prods ~= Production([foo, biz], foobiz, null);

		auto red = Reducer(prods);

		auto result = red.reduce([foo, foo, biz, foo, bar]);
		assert(result.reducesTo == foobar);
		assert(result.elementsConsumed == 2);

		result = red.reduce([foo, bar, foo, bar, baz]);
		assert(result.reducesTo == foobarbaz);
		assert(result.elementsConsumed == 3);

		result = red.reduce([foo, bar, foo, biz]);
		assert(result.reducesTo == foobiz);
		assert(result.elementsConsumed == 2);

		result = red.reduce([biz, bar, foo]);
		assert(result == result.init);
	}

private:

	GrammarTreeNode*[GrammarDefinition] trees;
}

