import grammardefinition;
import production;

@safe:

struct GrammarTreeNode {

	/// Postblit. Duplicates our edges map on copy
	@trusted
	this(this)
	{
		edges = edges.dup;
	}

	GrammarTreeNode* addChildAsNeeded(ref in GrammarDefinition def)
	{
		auto existing = def in edges;

		if (existing == null) {
			auto newNode = new GrammarTreeNode();
			edges[def] = newNode;
			return newNode;
		}
		else {
			return *existing;
		}
	}

	/// The syntax-directed translation of a production if this node
	/// represents the first element in a production and it has an SDT
	Production.SDTCallback translator;

	/// The reduction if this node represents the first element in a production
	GrammarDefinition* reduction;

	GrammarTreeNode*[GrammarDefinition] edges;
}

unittest
{
	GrammarTreeNode base;
	assert(base.translator == null);
	immutable auto nextDef = GrammarDefinition(ElementType.TERM, 42, 2);
	GrammarTreeNode* next = base.addChildAsNeeded(nextDef);
	immutable auto lastDef = GrammarDefinition(ElementType.NONTERM, 25, 64);
	GrammarTreeNode* last = next.addChildAsNeeded(lastDef);
	assert(*(nextDef in base.edges) == next);
	assert(*(lastDef in next.edges) == last);
	assert((nextDef in last.edges) == null);
}
