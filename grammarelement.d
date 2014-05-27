import grammardefinition;
import token;
import astnode;

interface GrammarElement {

	const Token* asTerminal(GrammarElementID id) const;

	const Token* asTerminal() const;

	ASTNode* asNonTerminal(GrammarElementID id);

	ASTNode* asNonTerminal();
}
