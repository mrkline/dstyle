@safe:

/// Used for line-ending related options
enum LineEnding {
	UNIX, ///< LF
	WINDOWS, ///< CR LF (or, rarely, LF CR)
	MAC, ///<  CR
	AUTO ///< Use whatever is most common in the file
}

/// Used for the placement of braces
enum BraceRule {
	SAME, ///< Braces start on the same line
	NEXT, ///< Braces start on the next line
	NEXT_INDENTED ///< Braces start on the next line, indented
}

/// Used for spacing
enum SpaceRule {
	NONE, ///< No space between items
	SINGLE, ///< Single space between items
	KEEP ///< Do not change spacing between items
}

/// Policy for using tab characters
enum TabPolicy {
	TABS, ///< Allow tab characters
	SPACES, ///< Expand all tab characters to spaces
}

TabPolicy tabPolicy = TabPolicy.TABS;

/// Policy for pointer declarations
enum PointerDeclarations {
	TYPE, ///< Place the pointer symbol (*, &, or &&) next to the type
	MIDDLE, ///< Place the pointer operator in between the type and the name
	NAME ///< Place the pointer operator next to the name
}

PointerDeclarations pointerDeclarations = PointerDeclarations.TYPE;

// Misc. stuff

/// Line ending to use
LineEnding endingToUse = LineEnding.UNIX;

/// true to trim trailing whitespace
bool trimTrailingWhitespace = true;

/// true to keep multiple statements on a line
bool keepOneLineStatements = true;

/// true to not break up a one-line { } block
bool keepOneLineBlocks = true;

/** break
 *  } else if {
 *  into
 *  }
 *  else if {
 */
bool breakSecondaryBlocks = true;

/// The desired size of the tab character, in spaces
/// (used for retabbing)
int tabSize = 4;

/// Indentation rules
struct IndentRules {
	bool namespaces = false; ///< True to indent the contents of namespaces
	bool classBodies = true; ///< true to indent the contents of class bodies
	bool enumValues = true; ///< True to indent values in enum declarations
	bool functionBodies = true; ///< true to indent the contents of function bodies
	bool blockBodies = true; ///< true to indent the contents of control blocks
	bool cases = true; ///< true to indent cases in switch bodies
	bool caseBodies = true; ///< true to indent the contents of case bodies
	bool breaks = true; ///< true to indent break statements at the end of case bodies
}

IndentRules indentRules;

/// Brace rules
struct BraceRules {
	BraceRule classes = BraceRule.SAME; ///< For class bodies
	BraceRule lambdas = BraceRule.SAME; ///< For lambdas and anonymous classes
	BraceRule functions = BraceRule.NEXT; ///< For functions/methods
	BraceRule enums = BraceRule.SAME; ///< For enums
	BraceRule blocks = BraceRule.SAME; ///< For control blocks
	BraceRule caseBlocks = BraceRule.SAME; ///< For case statement blocks
}

BraceRules braceRules;

/// Spacing rules
struct SpaceRules {
	SpaceRule operators = SpaceRule.SINGLE; ///< Space operators
	SpaceRule padParens = SpaceRule.NONE; ///< Pad the outside of parenthesis (usually just the left one)
	SpaceRule padInParens = SpaceRule.NONE; ///< Pad the inside of parenthesis
}

SpaceRules spaceRules;
