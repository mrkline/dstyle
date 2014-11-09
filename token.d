import grammarelement;

/// A token, scanned from a source file
class Token : GrammarElement {

	this(string r, int l, int c)
	{
		rep = r;
		line = l;
		col = c;
	}

	// TODO: Use alias this instead?
	@property size_t length() const { return rep.length; }

	override string toString()
	{
		return rep;
	}

	string rep; ///< The string representing the token
	immutable int line; ///< Line the token starts on
	immutable int col; ///< Column the token starts on
}

class NewlineToken : Token {

	this(string r, int l, int c)
	{
		super(r, l, c);
	}

	override string toString()
	{
		return `\n`;
	}
}

class SpaceToken : Token {

	this(string r, int l, int c)
	{
		super(r, l, c);
	}

	override string toString()
	{
		return `\s`;
	}
}
