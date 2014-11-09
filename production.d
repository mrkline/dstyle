import grammarelement;
import astnode;

import std.exception;

struct Production {

	alias ASTNode delegate(GrammarElement[]) SDTCallback;

	ClassInfo[] elements;

	ClassInfo reducesTo;

	SDTCallback translator;

	this(ClassInfo[] elems, ClassInfo to, SDTCallback trans)
	{
		enforce(elems.length > 0, "A production must have at least one element.");

		elements = elems;
		reducesTo = to;
		translator = trans;
	}
}
