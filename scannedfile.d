import token;

@safe:

/**
 * \brief Represents a scanned file, made of a list of tokens and a list of line endings
 *        (including trailing whitespace, if the user to keep it around for some reason)
 *
 * Ideally, this struct would be immutable - there should be no need to change tokens once they have been scanned.
 * This is not the case because some languages (I'm looking at you, C++) require some preliminary parsing
 * to figure out whether tokens are, for example, a less-than and greater-than operators or template deliminators.
 * To solve this problem, we'll do some initial parsing, possibly change some tokens as a result,
 * and then hand things off to the parser proper to build an AST.
 */
struct ScannedFile {

	string rawFile;
	Token[] tokens;
	int unixNewlines;
	int windowsNewlines;
	int macNewlines;

	this(string raw, Token[] toks, int un, int wn, int mn)
	{
		rawFile = raw;
		tokens = toks;
		unixNewlines = un;
		windowsNewlines = wn;
		macNewlines = mn;
	}

	/// Bad? http://www.reddit.com/r/IAmA/comments/1nl9at/i_am_a_member_of_facebooks_hhvm_team_a_c_and_d/ccjuis6
	this(this) {
		rawFile = rawFile.dup;
		tokens = tokens.dup;
	}
};
