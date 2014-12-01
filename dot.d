import std.array;
import std.conv;

import astnode;
import grammarelement;
import token;

string toDot(GrammarElement[] elements)
{
	auto declarations = Appender!string();
	auto connections = Appender!string();

	int uid = 0;

	string declare(Object o)
	{
		auto nodeName = "node_" ~ uid++.to!string;
		string label = o.toString();
		assert(label != null);
		declarations.writeln(nodeName, "[label=\"", label, "\"]");
		return nodeName;
	}

	void recursor(ASTNode node, string parentName)
	{
		string nodeName = declare(node);

		if (parentName != "")
			connections.writeln(parentName, " -> ", nodeName);

		foreach (child; node.children)
			recursor(child, nodeName);
	}

	foreach(element; elements) {

		Token asToken = cast(Token)element;

		if (asToken !is null) {
			declare(asToken);
			continue;
		}

		ASTNode asNode = cast(ASTNode)element;
		assert(asNode !is null); // If it's not a token, surely it's a node

		recursor(asNode, "");
	}

	auto outputBuilder = Appender!string();

	outputBuilder.writeln("digraph syntaxTree {", "\n");

	outputBuilder.writeln(declarations.data);
	outputBuilder.put(connections.data);

	outputBuilder.writeln("}");

	return outputBuilder.data;
}

pure void writeln(S...)(ref Appender!string app, S strings)
{
	foreach(s; strings)
		app ~= s.to!string;
	app ~= "\n";
}

