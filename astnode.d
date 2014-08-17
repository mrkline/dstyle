import grammardefinition;
import grammarelement;
import token;

import std.exception;

@safe:

class ASTNode : GrammarElement {

	enum CommonNontermIDs : GrammarElementID {
		Intlit, ///< Integer literal
		ID, ///< ID
		Value, ///< A simple value (literals, IDs, etc.)
		Product, ///< value, product * value
		Sum, ///< product, sum + product
		Statement ///< sum;
	}

	this(GrammarElementID i, ASTNode p = null)
	{
		this(GrammarDefinition(ElementType.Nonterm, i), p);
	}

	this(GrammarDefinition d, ASTNode p = null)
	{
		enforce(d.type == ElementType.Nonterm, "An AST node must be a non-terminal.");
		super(d);
		parent = p;
	}

	override const(Token) asTerminal(GrammarElementID) const { return null; }

	override const(Token) asTerminal() const { return null; }

	override ASTNode asNonTerminal(GrammarElementID i) { return def.id == i ? this : null; }

	override ASTNode asNonTerminal() { return this; }

	ASTNode parent;

	GrammarElement[] children;
}

class InnerASTNode : ASTNode {

	this(GrammarDefinition d, ASTNode p = null) { super(d, p); }

}
