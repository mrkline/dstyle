import grammardefinition;
import token;
import astnode;

@safe:

class GrammarElement {

	this(in GrammarDefinition d)
	{
		def = d;
	}

	abstract const(Token*) asTerminal(GrammarElementID id) const;

	abstract const(Token*) asTerminal() const;

	abstract ASTNode* asNonTerminal(GrammarElementID id);

	abstract ASTNode* asNonTerminal();

	immutable GrammarDefinition def;
}
