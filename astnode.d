import grammardefinition;
import grammarelement;
import token;

import std.exception;

@safe:

class ASTNode : GrammarElement {

	enum CommonNontermIDs : GrammarElementID {
		INTLIT, ///< Integer literal
		ID, ///< ID
		VALUE, ///< A simple value (literals, IDs, etc.)
		PRODUCT, ///< value, product * value
		SUM, ///< product, sum + product
		STATEMENT ///< sum;
	}

	this(GrammarElementID i, ASTNode* p = null)
	{
		this(GrammarDefinition(ElementType.NONTERM, i), p);
	}

	this(GrammarDefinition d, ASTNode* p = null)
	{
		enforce(d.type == ElementType.NONTERM, "You cannot have an AST node as a terminal.");
		super(d);
		parent = p;
	}

	override const(Token*) asTerminal(GrammarElementID) const { return null; }

	override const(Token*) asTerminal() const { return null; }

	override ASTNode* asNonTerminal(GrammarElementID i) { return def.id == i ? &this : null; }

	override ASTNode* asNonTerminal() { return &this; }

	ASTNode* parent;

	ASTNode*[] children;

}
