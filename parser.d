import grammarelement;
import astnode;
import precedence;
import production;
import reducer;
import token;

import std.algorithm;
import std.exception;

/*
 * The parser (and reducer) can operate on a series of ClassInfo IDs,
 * which is used mostly for testing purposes,
 * or actual grammar elements.
 * This is why both files consist largely of templates that take
 * either ClassInfo or element arguments (see isInfoOrElement).
 */

/// Either gets the ClassInfo of a grammar element,
/// or just returns the ClassInfo supplied to it.
ClassInfo infoOf(S)(S elem) if (isInfoOrElement!S)
{
	static if (is (S == ClassInfo))
		return elem;
	else
		return elem.classinfo;
}


/**
 * \brief A stupid shift-reduce parser.
 *
 * Does it suck? Probably. I have no delusions of grandeur.
 * However, I hope it is simple and effective.
 */
struct Parser {

	@disable this();

	/// Constructs a parser from a grammer (i.e. a list of productions)
	/// and any provided precedence rules
	this(Production[] grammar,
	     PrecedenceRule[ClassInfo] precedenceRules = (PrecedenceRule[ClassInfo]).init)
	{
		reducer = Reducer(grammar);
		precedence = precedenceRules;
	}

	/// Gets the precedence of a grammer element or its ID
	PrecedenceLevel precedenceOf(S)(S elem) if (isInfoOrElement!S)
	{
		auto rule = infoOf(elem) in precedence;
		if (rule)
			return rule.precedence;
		else
			return PrecedenceLevel.init;
	}

	/// Gets the associativity of a grammar element or its ID
	Associativity associativityOf(S)(S elem) if (isInfoOrElement!S)
	{
		auto rule = infoOf(elem) in precedence;
		if (rule)
			return rule.associativity;
		else
			return Associativity.init;
	}

	/**
	 * \brief Parses a series of tokens,
	 *        or simulates said parsing with a series of token IDs
	 *
	 * \param tokens The series of tokens or token IDs
	 * \returns The parse stack, which will either hold a completed AST
	 *          if a full parse was successful, or as much that could be parsed
	 *          plus whatever tokens/elements remain.
	 */
	auto parse(T)(T[] tokens) if (isInfoOrElement!T)
	{
		// If we're simulating a parse with IDs, our parse stack will be IDs.
		// Otherwise it will be grammar elements (tokens and AST nodes).
		static if (is(T == ClassInfo))
			alias T S;
		else
			alias GrammarElement S;

		// Gets the ID for the next token or token ID, if there is one
		ClassInfo lookaheadInfo()
		{
			if (tokens.length > 0) {
				return infoOf(tokens[0]);
			}
			else {
				return null;
			}
		}

		S[] parseStack;

		// Gets the top element of the stack
		S top() {
			enforce(parseStack.length > 0, "Top was called when the parse stack was empty.");
			return parseStack[$-1];
		}

		// Returns the highest precedence for items found in the stack
		PrecedenceLevel highestStackPrecedence() {
			auto precs = parseStack.map!(a => precedenceOf(a));
			return std.algorithm.reduce!((a, b) => a >= b ? a : b)(PrecedenceLevel.init, precs);
		}

		// Shifts an element from the token stream into the parse stack
		void shift() {
			parseStack ~= tokens[0];
			tokens = tokens[1 .. $];
		}

		// The shift-reduce loop:
		while (tokens.length > 0) {

			if (parseStack.length == 0 ||
				precedenceOf(lookaheadInfo) > highestStackPrecedence
				/* or precedence is the same and we're right associative? */) {
				shift();
			}
			else {
				// Try to reduce, otherwise shift
				if (!reduce(parseStack)) {
					shift();
				}
			}
		}

		// Once we've scanned everything, reduce as long as we can.
		while (reduce(parseStack)) { /* keep reducing */ }

		return parseStack;
	}

	// A really quick smoke test
	unittest
	{
		class Foo { }
		class Bar { }

		// A foo reduces to a bar
		auto foo = Foo.classinfo;
		auto bar = Bar.classinfo;

		auto fooToBar = Production([foo], bar, null);
		auto parser = Parser([fooToBar]);

		assert(parser.parse([foo]) == [bar]);
	}

	// Simulate a parse using only IDs
	unittest
	{
		class ID { }
		class Equals { }
		class Plus { }
		class Times { }

		auto id = ID.classinfo;
		auto equals = Equals.classinfo;
		auto plus = Plus.classinfo;
		auto times = Times.classinfo;

		class Exp { }
		class Assignment { }

		auto exp = Exp.classinfo;
		auto assignment = Assignment.classinfo;

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

	// Alright, time for the real deal.
	// Attempt a parse using tokens.
	unittest
	{
		class ID : Token {
			this(string name) { super(name, 0, 0); }
		}
		class Equals : Token {
			this() { super("=", 1, 1); }
		}
		class Plus : Token {
			this() { super("+", 2, 2); }
		}
		class Times : Token {
			this() { super("*", 3, 3); }
		}

		class IDNode : ASTNode {
			this(ID theID) { id = theID; }

			ID id;
		}

		class Sum : ASTNode {
			this(ASTNode l, ASTNode r)
			{
				left = l;
				right = r;
				left.parent = right.parent = this;
			}

			ASTNode left, right;
		}

		class Product : ASTNode {
			this(ASTNode l, ASTNode r)
			{
				left = l;
				right = r;
				left.parent = right.parent = this;
			}

			ASTNode left, right;
		}

		class Assignment : ASTNode {
			this(ASTNode l, ASTNode r)
			{
				left = l;
				right = r;
				left.parent = right.parent = this;
			}

			ASTNode left, right;
		}

		auto idProd = Production([ID.classinfo], IDNode.classinfo, (GrammarElement[] elems) {
			assert(elems.length == 1);
			assert(cast(ID)elems[0]);
			return new IDNode(cast(ID)elems[0]);
		});

		auto parser = Parser([idProd]);
		Token[] tokens = [new ID("foo")];

		auto idResult = parser.parse(tokens);
		assert(idResult.length == 1);
		assert(cast(IDNode)idResult[0]);
		assert((cast(IDNode)idResult[0]).id is tokens[0]);

		// TODO: Continue testing
	}

private:

	/// Reduces the stack using the reducer and
	/// returns true if some tokens were reduced
	bool reduce(S)(ref S[] parseStack) if (isInfoOrElement!S)
	{
		auto reduction = reducer.getReduction(parseStack);

		immutable consumed = reduction.elementsConsumed;

		if (consumed > 0) {
			// If this is a test run using IDs,
			// the result is just the ID of the reuction.
			static if (is(S == ClassInfo)) {
				auto result = reduction.reducesTo;
			}
			// If this is the real deal, call the syntax-directed translator
			// with the tokens being consumed by this reduction.
			else {
				ASTNode result = reduction.translator(parseStack[$ - consumed .. $]);

				// Quick sanity checks:
				// - The SDT didn't return null.
				enforce(result !is null, "A translator returned a null AST node");
				// - The SDT returned the type of element the production says it should.
				enforce(result.classinfo == reduction.reducesTo,
					"The translator returned a reduction that isn't the expected type");
			}

			// Slice off the elements of the stack we just reduced...
			parseStack = parseStack[0 .. $ - consumed];
			// ...and replace them with our reduction.
			parseStack ~= result;
		}

		return consumed > 0;
	}

	Reducer reducer;
	const PrecedenceRule[ClassInfo] precedence;
}
