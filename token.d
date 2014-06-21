import grammardefinition;
import grammarelement;
import astnode;

import std.exception;

@safe:

/// Common token types, used by the scanner and all languages.
/// Languages should obviously avoid using these values for other token types.
enum CommonTokenIDs : GrammarElementID {
	Space, ///< Tabs and spaces
	Newline, ///< A newline
	ID, ///< An ID, be it for a function, variable, etc.
	NumLit, ///< A numeric literal (int literal, float literal, etc.)
	StrLit, ///< A string literal
	FlowCond, ///< A control flow keyword with a condition (if, while, for, etc.)
	Flow, ///< A control flow keyword without a condition (else, do, try, etc.)
	UncommonStart ///< Gives a starting value for language-specific token types
}

/// A token, scanned from a source file
class Token : GrammarElement {

	this(GrammarElementID i, string r, int l, int c)
	{
		this(GrammarDefinition(ElementType.Term, i), r, l, c);
	}

	this(GrammarDefinition d, string r, int l, int c)
	{
		enforce(d.type == ElementType.Term, "A token cannot be a non-terminal.");
		super(d);
		rep = r;
		line = l;
		col = c;
	}

	@property size_t length() const { return rep.length; }

	override const(Token) asTerminal(GrammarElementID i) const { return def.id == i ? this : null; }

	override const(Token) asTerminal() const { return this; }

	override ASTNode asNonTerminal(GrammarElementID) { return null; }

	override ASTNode asNonTerminal() { return null; }

	override string toString()
	{
		switch (def.id) {
			case CommonTokenIDs.Newline:
			return "\\n";

			case CommonTokenIDs.Space:
			return "\\s";

			default:
			return rep;
		}
	}

	string rep; ///< The string representing the token
	immutable int line; ///< Line the token starts on
	immutable int col; ///< Column the token starts on
}
