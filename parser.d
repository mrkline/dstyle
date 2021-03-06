import grammardefinition;
import grammarelement;
import astnode;
import precedence;
import production;
import reducer;
import token;

import std.algorithm;
import std.exception;

// @safe:

/**
 * \brief A stupid shift-reduce parser.
 *
 * Does it suck? Probably. I have no delusions of grandeur.
 * However, I hope it is simple and effective.
 */
struct Parser {

	@disable this();

	@trusted // .keyas and .values is a system call apparently
	this(in Production[] grammar,
	     in PrecedenceRule[GrammarDefinition] precedenceRules = (PrecedenceRule[GrammarDefinition]).init)
	in
	{
		foreach (k; precedenceRules.keys) {
			assert(k != k.init);
		}
		foreach (v; precedenceRules.values) {
			// Do not allow any precedence rule to have negative or zero precedence.
			assert(v.precedence > v.precedence.init);
		}
	}
	body
	{
		reducer = Reducer(grammar);
		precedence = precedenceRules;
	}

	auto parse(T)(T[] tokens) if (is(T == GrammarDefinition) || is(T == Token))
	{
		static if (is(T == GrammarDefinition))
			alias T S;
		else
			alias GrammarElement S;

		GrammarDefinition defOf(S elem) {
			static if (is (S == GrammarDefinition))
				return elem;
			else
				return elem.def;
		}

		GrammarDefinition lookaheadDef()
		{
			if (tokens.length > 0) {
				return defOf(tokens[0]);
			}
			else {
				return GrammarDefinition.init;
			}
		}

		PrecedenceLevel precedenceOf(T token) {
			auto rule = defOf(token) in precedence;
			if (rule)
				return rule.precedence;
			else
				return PrecedenceLevel.init;
		}

		Associativity associativityOf(T token) {
			auto rule = defOf(token) in precedence;
			if (rule)
				return rule.associativity;
			else
				return Associativity.init;
		}

		// auto lastPrecedence = PrecedenceLevel.init;

		S[] parseStack;

		S top() {
			enforce(parseStack.length > 0, "Top was called when the parse stack was empty.");
			return parseStack[$-1];
		}

		PrecedenceLevel highestStackPrecedence() {
			auto precs = parseStack.map!(a => precedenceOf(a));
			return std.algorithm.reduce!((a, b) => a >= b ? a : b)(PrecedenceLevel.init, precs);
		}

		void shift() {
			parseStack ~= tokens[0];
			tokens = tokens[1 .. $];
		}

		while (tokens.length > 0) {
			if (parseStack.length >= 2 &&
				defOf(parseStack[$-2]) == lookaheadDef && // Just use highest?
				associativityOf(lookaheadDef) ==  Associativity.none) {
				// Spaz out. We just found something trying to be associative when it can't be.
				// This would trip on a = a =
			}

			if (parseStack.length == 0 ||
				precedenceOf(lookaheadDef) > highestStackPrecedence
				/* or precedence is the same and we're right associative? */) {
				// Shift
				shift();
			}
			else {
				if (!reduce(parseStack)) {
					shift();
				}
			}
		}

		// Once we've scanned everything, reduce as long as we can.
		while (reduce(parseStack)) { /* keep reducing */ }

		return parseStack;
	}

	unittest
	{
		// A foo reduces to a bar
		auto foo = GrammarDefinition(ElementType.Term, 1);
		auto bar = GrammarDefinition(ElementType.Nonterm, 2);

		auto fooToBar = Production([foo], bar, null);
		auto parser = Parser([fooToBar]);

		assert(parser.parse([foo]) == [bar]);
	}

	unittest
	{
		int uid = 0;
		auto id = GrammarDefinition(ElementType.Term, ++uid);
		auto equals = GrammarDefinition(ElementType.Term, ++uid);
		auto plus = GrammarDefinition(ElementType.Term, ++uid);
		auto times = GrammarDefinition(ElementType.Term, ++uid);

		auto exp = GrammarDefinition(ElementType.Nonterm, ++uid);
		auto assignment = GrammarDefinition(ElementType.Nonterm, ++uid);

		auto precedence = [
			equals : PrecedenceRule(1),
			plus : PrecedenceRule(2),
			times : PrecedenceRule(3),
			id : PrecedenceRule(4)
		];

		auto expProd = Production([id], exp, null);
		auto sumProd = Production([exp, plus, exp], exp, null);
		auto productProd = Production([exp, times, exp], exp, null);
		auto assignmentProd = Production([exp, equals, exp], assignment, null);

		auto parser = Parser([expProd, assignmentProd, sumProd, productProd], precedence);

		assert(parser.parse([id]) == [exp]);
		assert(parser.parse([exp, equals, exp]) == [assignment]);
		assert(parser.parse([id, equals, id]) == [assignment]);
		assert(parser.parse([exp, plus, exp]) == [exp]);
		assert(parser.parse([id, equals, id, plus, id]) == [assignment]);
		assert(parser.parse([id, times, id]) == [exp]);
		assert(parser.parse([id, equals, id, plus, id, times, id]) == [assignment]);

		// It appears that things are working properly,
		// but we need an actual tree to be sure.
	}

private:

	/// Returns true if some tokens were reduced
	bool reduce(S)(ref S[] parseStack) if (is(S == GrammarDefinition) || is(S == GrammarElement))
	{
		auto reduction = reducer.reduce(parseStack);

		immutable consumed = reduction.elementsConsumed;

		if (consumed > 0) {
			static if (is(S == GrammarDefinition)) {
				auto result = reduction.reducesTo;
			}
			else {
				ASTNode result = reduction.translator(parseStack[$ - consumed .. $]);

				enforce(result != null, "A translator returned a null AST node");
				enforce(result.def == reduction.reducesTo,
					"The translator returned a reduction that isn't the expected type");
			}

			parseStack = parseStack[0 .. $ - consumed];
			parseStack ~= result;
		}

		return consumed > 0;
	}

	Reducer reducer;
	const PrecedenceRule[GrammarDefinition] precedence;
}
