@safe:

alias int GrammarElementID;

/// Specifies an element's type (terminal or nonterminal)
enum ElementType {
	TERM, ///< Terminal
	NONTERM ///< Nonterminal
}

/// A definition of a single terminal or nonterminal
struct GrammarDefinition {
	ElementType type; ///< The element's type (terminal or nonterminal)
	GrammarElementID id; ///< The element's ID

	/// Trivial constructor
	this(ElementType t, GrammarElementID i)
	{
		type = t;
		id =i;
	}
}
