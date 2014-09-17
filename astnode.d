import grammarelement;

@safe:

class ASTNode : GrammarElement {

	this(ASTNode p = null)
	{
		parent = p;
	}

	ASTNode parent;
}
