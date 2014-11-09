/// Used for line-ending related options
enum LineEnding {
	Unix, ///< LF
	WindowsS, ///< CR LF (or, rarely, LF CR)
	Mac, ///<  CR
	Auto ///< Use whatever is most common in the file
}

/// Used for the placement of braces
enum BraceRule {
	Same, ///< Braces start on the same line
	Next, ///< Braces start on the next line
	NextIndented ///< Braces start on the next line, indented
}

/// Used for spacing
enum SpaceRule {
	None, ///< No space between items
	Single, ///< Single space between items
	Keep ///< Do not change spacing between items
}

/// Policy for using tab characters
enum TabPolicy {
	Tabs, ///< Allow tab characters
	Spaces, ///< Expand all tab characters to spaces
}

TabPolicy tabPolicy = TabPolicy.Tabs;

/// Policy for pointer declarations
enum PointerDeclarations {
	Type, ///< Place the pointer symbol (*, &, or &&) next to the type
	Middle, ///< Place the pointer operator in between the type and the name
	Name ///< Place the pointer operator next to the name
}

PointerDeclarations pointerDeclarations = PointerDeclarations.Type;

// Misc. stuff

/// Line ending to use
LineEnding endingToUse = LineEnding.Unix;

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
	BraceRule classes = BraceRule.Same; ///< For class bodies
	BraceRule lambdas = BraceRule.Same; ///< For lambdas and anonymous classes
	BraceRule functions = BraceRule.Next; ///< For functions/methods
	BraceRule enums = BraceRule.Same; ///< For enums
	BraceRule blocks = BraceRule.Same; ///< For control blocks
	BraceRule caseBlocks = BraceRule.Same; ///< For case statement blocks
}

BraceRules braceRules;

/// Spacing rules
struct SpaceRules {
	SpaceRule operators = SpaceRule.Single; ///< Space operators
	SpaceRule padParens = SpaceRule.None; ///< Pad the outside of parenthesis (usually just the left one)
	SpaceRule padInParens = SpaceRule.None; ///< Pad the inside of parenthesis
}

SpaceRules spaceRules;
