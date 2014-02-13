import grammardefinition;

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
