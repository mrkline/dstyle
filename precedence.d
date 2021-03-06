
@safe:

enum Associativity {
	none, ///< Non-associative
	left, ///< Left associative
	right ///< Right associative
}

alias int PrecedenceLevel;

/// Precedence rules related to grammar elements
struct PrecedenceRule {
	PrecedenceLevel precedence; ///< higher number is higher precedence
	Associativity associativity;

	// Left associative is the most common
	this(PrecedenceLevel p, Associativity a = Associativity.left)
	in
	{
		assert(p > p.init);
	}
	body
	{
		precedence = p;
		associativity = a;
	}
}

pure bool precedes(T)(T l, T r) if (is(T == PrecedenceRule) || is(T == PrecedenceLevel))
{
	static if (is(T == PrecedenceRule)) {
		return l.precedence > r.precedence;
	}
	else {
		return l > r;
	}
}
