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

TabPolicy tabPolicy;

/// Policy for pointer declarations
enum PointerDeclarations {
	TYPE, ///< Place the pointer symbol (*, &, or &&) next to the type
	MIDDLE, ///< Place the pointer operator in between the type and the name
	NAME ///< Place the pointer operator next to the name
}

PointerDeclarations pointerDeclarations;

// Misc. stuff

/// Line ending to use
LineEnding endingToUse;

/// true to trim trailing whitespace
bool trimTrailingWhitespace;

/// true to keep multiple statements on a line
bool keepOneLineStatements;

/// true to not break up a one-line { } block
bool keepOneLineBlocks;

/** break
 *  } else if {
 *  into
 *  }
 *  else if {
 */
bool breakSecondaryBlocks;

/// The desired size of the tab character, in spaces
/// (used for retabbing)
int tabSize;

/// Indentation rules
struct IndentRules {
	bool namespaces; ///< True to indent the contents of namespaces
	bool classBodies; ///< true to indent the contents of class bodies
	bool enumValues; ///< True to indent values in enum declarations
	bool functionBodies; ///< true to indent the contents of function bodies
	bool blockBodies; ///< true to indent the contents of control blocks
	bool cases; ///< true to indent cases in switch bodies
	bool caseBodies; ///< true to indent the contents of case bodies
	bool breaks; ///< true to indent break statements at the end of case bodies
}

IndentRules indentRules;

/// Brace rules
struct BraceRules {
	BraceRule classes; ///< For class bodies
	BraceRule lambdas; ///< For lambdas and anonymous classes
	BraceRule functions; ///< For functions/methods
	BraceRule enums; ///< For enums
	BraceRule blocks; ///< For control blocks
	BraceRule caseBlocks; ///< For case statement blocks
}

BraceRules braceRules;

/// Spacing rules
struct SpaceRules {
	SpaceRule operators; ///< Space operators
	SpaceRule padParens; ///< Pad the outside of parenthesis (usually just the left one)
	SpaceRule padInParens; ///< Pad the inside of parenthesis
}

SpaceRules spaceRules;
