import grammardefinition;
import grammarelement;
import token;

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
		id = i;
		parent = p;
	}

	override const Token* asTerminal(GrammarElementID) const { return null; }

	override const Token* asTerminal() const { return null; }

	override ASTNode* asNonTerminal(GrammarElementID i) { return id == i ? &this : null; }

	override ASTNode* asNonTerminal() { return &this; }

	GrammarElementID id;

	ASTNode* parent;

	ASTNode*[] children;

}
