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

		bool ret;
		if ((c == '\r' || c == '\n') && c != last)
			ret = true;
		else
			ret = false;

		last = c;

		return ret;
	}

	// Will be removed by the list of finalists before it can be checked if it is not one
	@property override bool isInFinalState() const { return true; }

	@property override GrammarElementID tokenID() const { return CommonTokenIDs.NEWLINE; }

	@property override string name() const { return "Newline"; }

private:
	char last = '\0';
	char num = 0;
}

class WhitespaceGenerator : TokenGenerator {

	override void reset() { }

	override bool next(char c) { return c == ' ' || c == '\t'; }

	@property override bool isInFinalState() const { return true; }

	@property override GrammarElementID tokenID() const { return CommonTokenIDs.SPACE; }

	@property override string name() const { return "Whitespace"; }
}
