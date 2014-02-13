import grammardefinition;

@safe:

/// Common token types, used by the scanner and all languages.
/// Languages should obviously avoid using these values for other token types.
/// Values are negative to avoid conflicts
enum CommonTokenIDs : GrammarElementID {
	SPACE, ///< Tabs and spaces
	NEWLINE, ///< A newline
	ID, ///< An ID, be it for a function, variable, etc.
	NUMLIT, ///< A numeric literal (int literal, float literal, etc.)
	STRLIT, ///< A string literal
	FLOW_COND, ///< A control flow keyword with a condition (if, while, for, etc.)
	FLOW, ///< A control flow keyword without a condition (else, do, try, etc.)
	UNCOMMON_START ///< Gives a starting value for language-specific token types
}

/// A token, scanned from a source file
class Token {

	this(GrammarElementID i, string r, int l, int c)
	{
		id = i;
		rep = r;
		line = l;
		col = c;
	}

	@property size_t length() const { return rep.length; }

	override string toString()
	{
		switch (id) {
			case CommonTokenIDs.NEWLINE:
			return "\\n";

			case CommonTokenIDs.SPACE:
			return "\\s";

			default:
			return rep;
		}
	}

	immutable GrammarElementID id;
	string rep; ///< The string representing the token
	immutable int line; ///< Line the token starts on
	immutable int col; ///< Column the token starts on
}
