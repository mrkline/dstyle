import production;

alias GrammarTreeNode*[ClassInfo] GrammarTree;

/**
 * \brief Search a grammar tree for a given ClassInfo or
 *        that the ClassInfo of a base class.
 *
 * For a parser-related example, a Sum or a Product might be a sub-type of
 * an Expression, so when using a production that takes an Expression,
 * we'd want to take any of its sub-types.
 */
static GrammarTreeNode** findClassOrBase(GrammarTree haystack, ClassInfo needle)
{
	// Walk up the class hierarchy, looking for a match in the haystack.
	for (ClassInfo ci = needle; ci !is null; ci = ci.base) {
		GrammarTreeNode** ret =  ci in haystack;
		if (ret != null)
			return ret;
	}
	return null;
}


// A tree of grammar element definitions (i.e. ClassInfos)
// used for reducing grammar elements.
struct GrammarTreeNode {

	// Creates a child node for the given definition
	// if one does not already exist.
	GrammarTreeNode* createChildAsNeeded(ClassInfo def)
	{
		auto existing = def in edges;

		if (existing is null) {
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

	GrammarTree edges;
}

unittest
{
	class NextDef { }
	class LastDef { }

	auto nextDef = NextDef.classinfo;
	auto lastDef = LastDef.classinfo;

	GrammarTreeNode base;
	assert(base.translator == null);
	GrammarTreeNode* next = base.createChildAsNeeded(NextDef.classinfo);
	GrammarTreeNode* last = next.createChildAsNeeded(LastDef.classinfo);
	assert(*(nextDef in base.edges) == next);
	assert(*(lastDef in next.edges) == last);
	assert((nextDef in last.edges) == null);
}
