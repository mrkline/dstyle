import std.ascii;

import grammardefinition;
import token;

@safe:

/// Interface that represents a state machine that can generate a token in the scanner.
interface TokenGenerator {

	/// Resets the generator to its starting state, ready to take its first character
	void reset();

	/// Accepts the next character (or doesn't).
	/// \returns true if the machine can accept the given character, false if it cannot
	bool next(char c);

	/// Returns true if the generator's current state is a final state
	@property bool isInFinalState() const;

	/// Returns the type of token that this generator creates
	@property GrammarElementID tokenID() const;

	@property string name() const;

}

class NewlineGenerator : TokenGenerator {

	override void reset()
	{
		last = '\0';
		num = 0;
	}

	override bool next(char c)
	{
		if (++num > 2)
			return false;

		immutable bool ret = (c == '\r' || c == '\n') && c != last;
		last = c;

		return ret;
	}

	// Will be removed by the list of finalists before it can be checked if it is not one
	@property override bool isInFinalState() const { return true; }

	@property override GrammarElementID tokenID() const { return CommonTokenIDs.Newline; }

	@property override string name() const { return "Newline"; }

private:
	char last = '\0';
	char num = 0;
}

class WhitespaceGenerator : TokenGenerator {

	override void reset() { }

	override bool next(char c) { return c == ' ' || c == '\t'; }

	@property override bool isInFinalState() const { return true; }

	@property override GrammarElementID tokenID() const { return CommonTokenIDs.Space; }

	@property override string name() const { return "Whitespace"; }
}

class StaticTokenGenerator : TokenGenerator {

	this(string tok, GrammarElementID ttype)
	{
		token = tok;
		type = ttype;
		idx = 0;
	}

	override void reset() { idx = 0; }

	override bool next(char c)
	{
		if (idx >= token.length)
			return false;

		return token[idx++] == c;
	}

	@property override bool isInFinalState() const { return idx == token.length; }

	@property override GrammarElementID tokenID() const { return type; }

	@property override string name() const { return token; }

private:
	immutable string token;
	immutable GrammarElementID type;
	size_t idx;
}

/// Recognizes C-style IDs
class IDTokenGenerator : TokenGenerator {

	override void reset() { hasNonDigit = false; }

	override bool next(char c)
	{
		if (isAlpha(c) || c == '_' || c < 0) {
			hasNonDigit = true;
			return true;
		}

		if (isDigit(c) && hasNonDigit)
			return true;

		return false;
	}

	@property override bool isInFinalState() const { return true; }

	@property override GrammarElementID tokenID() const { return CommonTokenIDs.Space; }

	@property override string name() const { return "ID"; }

private:
	bool hasNonDigit = false;
}
