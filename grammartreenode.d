import grammardefinition;

import std.stdio;

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

	/// \brief A pointer to a grammar definition if this is the first element in a production,
	///        otherwise null
	GrammarDefinition* reduction;

	GrammarTreeNode*[GrammarDefinition] edges;
}

@trusted:

unittest
{
	writeln("Beginning grammar tree node test");
	GrammarTreeNode base;
	assert(base.reduction == null);
	immutable GrammarDefinition nextDef = GrammarDefinition(ElementType.TERM, 42, 2);
	GrammarTreeNode* next = base.addChildAsNeeded(nextDef);
	immutable GrammarDefinition lastDef = GrammarDefinition(ElementType.NONTERM, 25, 64);
	GrammarTreeNode* last = next.addChildAsNeeded(lastDef);
	assert(*(nextDef in base.edges) == next);
	assert(*(lastDef in next.edges) == last);
	assert((nextDef in last.edges) == null);
}
