import grammarelement;

class ASTNode : GrammarElement {

	this(ASTNode p = null)
	{
		parent = p;
	}

	ASTNode parent;
}
