import config;
import log;
import scannedfile;
import token;
import tokengenerator;

import std.algorithm;
import std.conv;
import std.file; // For unit tests
import std.range;
import std.uni;

@safe:

ScannedFile scanFile(string file, TokenGenerator[] generators)
{
	scope(failure) logCacheFlush("scanloop");

	Token[] fileTokens;

	int line = 1;
	int col = 1;

	int unixNewlines = 0;
	int windowsNewlines = 0;
	int macNewlines = 0;

	// Generators that are still valid for the current sequence. When this list becomes empty,
	// - If we have a finalist, the sequence is that token
	// - If we have no finalists, the sequence is unrecognized
	TokenGenerator[] contenders = generators.dup;

	// Generators which reached a final state in the last character
	TokenGenerator[] finalists;

	// The last time we had a viable finalist. Fall back to this once all contenders drop out.
	int rewindTo;

	int startingLine = line;
	int startingCol = col;
	string token = file;
	int tokenStart = 0;


	// Loop through the buffer. Each iteration of the loop, feed the generators a character
	// and drop out the ones that do not accept it.
	// When all contenders drop out, check finalists for the last winner.
	// If no generator ever reaches a final state, we have an unrecognized character.
	for (int i = 0; i < file.length; ++i) {

		immutable char c = file[i];

		// Reintroduce logging later
		if (isGraphical(c))
			logCacheDebug("scanloop", "char is " ~ c);
		else if (c < 0 ) // Non-ASCII characters in UTF-8 are negative
			logCacheDebug("scanloop", "char is non-ASCII");
		else
			logCacheDebug("scanloop", "char is \\w");

		// Increment the column counter per space
		if (c == ' ') {
			++col;
		}
		else if (c == '\t') {
			// Indent to the next tab stop
			col += config.tabSize - ((col - 1) % config.tabSize);
		}

		// Remove all contenders that don't accept the next character
		for (int it = 0; it != contenders.length;) {
			if (contenders[it].next(c)) {
				++it;
			}
			else {
				logCacheDebug("scanloop", contenders[it].name ~ " dropping out");
				contenders = contenders.remove(it);
			}
		}

		// If we're out of contenders, check the last time we had finalists
		if (contenders.length == 0) {

			// Bad token
			if (finalists.length == 0) {
				string badToken = file[tokenStart .. i];
				throw new Exception("Unrecognized token: " ~ badToken);
			}
			// Ambiguous scanner
			if (finalists.length > 1) {
				// Throw invalid argument, since the problem is with our combination of generators
				throw new Exception("Ambiguous combination of tokens (multiple token matches of the same length)");
			}

			// We have a single finalist
			const winner = finalists.front;
			fileTokens ~= winner.getToken(file[tokenStart .. i], startingLine, startingCol);

			logInfo("token " ~ fileTokens.back.toString() ~
				" (" ~ startingLine.to!string ~ ":" ~ startingCol.to!string ~ ")");
			logCacheClear("scanloop");

			// If the winner is a newline, figure out what kind it is and add to that tally
			if (cast(NewlineToken)fileTokens.back) {
				if (fileTokens.back.length == 2)
					++windowsNewlines;
				else if (file[tokenStart] == '\n')
					++unixNewlines;
				else
					++macNewlines;

				// Add one to the line, reset the column
				++line;
				col = 1;
			}

			// Reset the works
			tokenStart = i;
			startingLine = line;
			startingCol = col;
			contenders = generators.dup;
			foreach (gen; generators)
				gen.reset();
			finalists = finalists.init;
			i = rewindTo; // Fall back to when our last finalist finished
		}
		else {
			TokenGenerator[] newFinalists;
			foreach (p; contenders) {
				if (p.isInFinalState)
					newFinalists ~= p;
			}
			if (newFinalists.length != 0) {
				finalists = newFinalists;
				// Our fallback point becomes this character
				rewindTo = i;
			}
		}
	}

	// Process the last token

	// Bad token
	if (finalists.empty) {
		string badToken = file[tokenStart .. $];
		throw new Exception("Unrecognized token: " ~ badToken);
	}
	// Ambiguous scanner
	if (finalists.length > 1) {
		// Throw invalid argument, since the problem is with our combination of generators
		throw new Exception("Ambiguous combination of tokens (multiple token matches of the same length");
	}

	// We have a single finalist
	TokenGenerator winner = finalists.front;
	fileTokens ~= winner.getToken(file[tokenStart .. $], startingLine, startingCol);

	logInfo("token " ~ fileTokens.back.toString() ~
		" (" ~ startingLine.to!string ~ ":" ~ startingCol.to!string ~ ")");
	logCacheClear("scanloop");

	if (cast(NewlineToken)fileTokens.back) {
		if (fileTokens.back.length == 2)
			++windowsNewlines;
		else if (file[tokenStart] == '\n')
			++unixNewlines;
		else
			++macNewlines;
	}

	// We're done. No need to reset

	return ScannedFile(file, fileTokens, unixNewlines, windowsNewlines, macNewlines);
}

@trusted:

unittest
{
	auto scanned = scanFile(readText("testfiles/newline.txt"), [new NewlineGenerator]);
	assert(scanned.unixNewlines == 1);
	assert(scanned.windowsNewlines == 2);
	assert(scanned.macNewlines == 1);
}

unittest
{
	TokenGenerator[] gens;
	gens ~= new NewlineGenerator();
	gens ~= new WhitespaceGenerator();
	auto scanned = scanFile(readText("testfiles/whitespace.txt"), gens);
	assert(scanned.unixNewlines == 4);
	assert(scanned.windowsNewlines == 0);
	assert(scanned.macNewlines == 0);
	// Assert that the newlines are indented properly
	assert(scanned.tokens[0].col == 1);
	assert(scanned.tokens[2].col == 5);
	assert(scanned.tokens[4].col == 5);
	assert(scanned.tokens[6].col == 5);
}
