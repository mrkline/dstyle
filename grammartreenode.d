import production;

struct GrammarTreeNode {

	GrammarTreeNode* addChildAsNeeded(ClassInfo def)
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
	ClassInfo reduction;

	GrammarTreeNode*[ClassInfo] edges;
}

unittest
{
	class NextDef { }
	class LastDef { }

	auto nextDef = NextDef.classinfo;
	auto lastDef = LastDef.classinfo;

	GrammarTreeNode base;
	assert(base.translator == null);
	GrammarTreeNode* next = base.addChildAsNeeded(NextDef.classinfo);
	GrammarTreeNode* last = next.addChildAsNeeded(LastDef.classinfo);
	assert(*(nextDef in base.edges) == next);
	assert(*(lastDef in next.edges) == last);
	assert((nextDef in last.edges) == null);
}
