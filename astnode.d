import grammarelement;

class ASTNode : GrammarElement {

	this(ASTNode p = null)
	{
		parent = p;
	}

	abstract @property ASTNode[] children();

	ASTNode parent;
}

mixin template NoChildren()
{
	override @property ASTNode[] children()
	{
		return null;
	}
}

mixin template BinaryChildren()
{
	override @property ASTNode[] children()
	{
		return [left, right];
	}
}
