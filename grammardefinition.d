@safe:

alias int GrammarElementID;

/// Specifies an element's type (terminal or nonterminal)
enum ElementType {
	TERM, ///< Terminal
	NONTERM ///< Nonterminal
}

/// A definition of a single terminal or nonterminal
struct GrammarDefinition {
	immutable ElementType type; ///< The element's type (terminal or nonterminal)
	immutable GrammarElementID id; ///< The element's ID
	immutable int precedence; ///< Lower means sooner in the order of operations. Mostly for terminals

	/// Trivial constructor
	this(ElementType t, GrammarElementID i, int prec = int.max)
	{
		type = t;
		id =i;
		precedence = prec;
	}
}
