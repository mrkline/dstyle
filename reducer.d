import grammartreenode;
import grammarelement;
import production;

import std.algorithm;
import std.exception;

// TODO: Add logging


/**
 * Indicates whether or not a given type is either ClassInfo
 * (i.e. a grammar element ID) or a grammar element.
 *
 * The reducer (and parser) can operate on a series of ClassInfo IDs,
 * which is used mostly for testing purposes,
 * or actual grammar elements.
 */
enum bool isInfoOrElement(T) = is(T == ClassInfo) || is(T : GrammarElement);

/**
 * \brief Takes a parse stack from a shift-reduce parser
 *        and reduces as much of the top as possible to a terminal
 *
 * To do this, we'll take our grammar and use it to build a graph,
 * then follow that graph to the furthest leaf.
 */
struct Reducer {

	@disable this();

	this(Production[] grammar)
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

			for (int i = cast(int)production.elements.length - 2; i >= 0; --i) {
				// Add nodes going backwards to the start of the production.
				currentNode = currentNode.addChildAsNeeded(production.elements[i]);
			}

			// If the current node already has a reduction, we have an ambiguous grammar.
			enforce(currentNode.translator is null && currentNode.reduction is null,
				"The provided grammar is ambiguous");

			// At the end of the chain, set the reduction
			currentNode.translator = production.translator;
			currentNode.reduction = production.reducesTo;
		}
	}

	unittest
	{
		class GD1 { }
		class GD2 { }
		class GD3 { }

		auto gd1 = GD1.classinfo;
		auto gd2 = GD2.classinfo;
		auto gd3 = GD3.classinfo;

		class Red1 { }
		class Red2 { }

		auto reduction1 = Red1.classinfo;
		auto reduction2 = Red2.classinfo;

		auto prod1 = Production([gd1, gd2, gd3], reduction1, null);
		auto prod2 = Production([gd1, gd2, gd3], reduction2, null);

		// Should be ambiguous
		assertThrown(Reducer([prod1, prod2]));
	}

	struct ReductionResult {
		Production.SDTCallback translator;
		ClassInfo reducesTo;
		int elementsConsumed;
	}

	/**
	 * \brief Reduces a series of grammar elements to a new one.
	 * \param stack The current parse stack.
	 *              This could either just be a stack of grammer element IDs
	 *              (mostly just used for debugging)
	 *              or an actual stack of GrammarElements
	 * \returns ReductionResult.init if no reduction can be made.
	 *          If one can be made, a result contaitning the translator
	 *          that yields the reduction and the number of elements
	 *          consumed by it
	 *
	 * The elements on the stack are examined from back to front.
	 *
	 * We could call the translator and modify the stack ourselves,
	 * but we'll leave that work to the caller.
	 *
	 */
	ReductionResult getReduction(S)(S[] stack) if (isInfoOrElement!S)
	{
		auto pop = {
			if (stack.length == 0)
				return null;

			static if (is(S == ClassInfo)) {
				auto ret = stack[$-1];
			}
			else {
				// TODO: If we don't cast this to an object, it returns
				// the classinfo of the GrammarElement interface.
				// Should we just stop using the marker interface GrammarElement?
				auto ret = (cast(Object)stack[$-1]).classinfo;
			}
			stack = stack[0 .. $-1];
			return ret;
		};

		ReductionResult ret;
		int consumed;

		// Descend our tree as far as we can,
		// then note the translator for this reduction and what it reduces to.
		for (GrammarTreeNode** curr = pop() in trees; curr != null;
		     curr = pop() in (*curr).edges) {
			++consumed;
			if ((*curr).reduction !is null) {
				ret.translator = (*curr).translator;
				ret.reducesTo = (*curr).reduction;
				ret.elementsConsumed = consumed;
			}
		}

		return ret;
	}

	unittest
	{
		class Foo { }
		class Bar { }

		// A foo reduces to a bar
		auto foo = Foo.classinfo;
		auto bar = Bar.classinfo;

		auto fooToBar = Production([foo], bar, null);
		auto red = Reducer([fooToBar]);

		assert(red.getReduction([foo]).reducesTo is bar);
	}

	unittest
	{
		class Foo { }
		class Bar { }
		class Baz { }
		class Biz { }

		auto foo = Foo.classinfo;
		auto bar = Bar.classinfo;
		auto baz = Baz.classinfo;
		auto biz = Biz.classinfo;

		class FooBar { }
		class FooBarBaz { }
		class FooBiz { }

		auto foobar = FooBar.classinfo;
		auto foobarbaz = FooBarBaz.classinfo;
		auto foobiz = FooBiz.classinfo;

		Production[] prods;
		// A foo and a bar reduce to a foobar
		prods ~= Production([foo, bar], foobar, null);
		// A foo, bar, and baz reduce to a foobarbaz
		prods ~= Production([foo, bar, baz], foobarbaz, null);
		// A foo and a biz reduce to a foobiz
		prods ~= Production([foo, biz], foobiz, null);

		auto red = Reducer(prods);

		auto result = red.getReduction([foo, foo, biz, foo, bar]);
		assert(result.reducesTo is foobar);
		assert(result.elementsConsumed == 2);

		result = red.getReduction([foo, bar, foo, bar, baz]);
		assert(result.reducesTo is foobarbaz);
		assert(result.elementsConsumed == 3);

		result = red.getReduction([foo, bar, foo, biz]);
		assert(result.reducesTo is foobiz);
		assert(result.elementsConsumed == 2);

		result = red.getReduction([biz, bar, foo]);
		assert(result is result.init);
	}

private:

	GrammarTreeNode*[ClassInfo] trees;
}

