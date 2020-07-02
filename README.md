# dstyle

dstyle is a code beautifier, similar to
[Astyle](http://astyle.sourceforge.net/) or [Uncrustify](http://uncrustify.sourceforge.net/).

## Design Goals

- Use the standard code parsing techniques used by compilers (scanner -> parser -> AST)

- Allow more leeway when reformatting
  (such as aligning one function actual with the user's choice of the one on the line above).
  While other beautifiers would reformat
	```c++
	bar = foo(true, 42, "string one",
	                    "string two");
	```
  to
	```c++
	bar = foo(true, 42, "string one",
	          "string two");
	```
  or worse,
	```c++
	FileSource fs(file.c_str(), true,
		new HashFilter(hash,
			new HexEncoder(
				new StringSink(digest)
			)
		)
	);
	```
  to
	```c++
	FileSource fs(file.c_str(), true,
	              new HashFilter(hash,
	                             new HexEncoder(
	                                 new StringSink(digest)
	                             )
	                            )
	             );
	```
  we want to preserve the original formatting in both cases.

- Avoid global state so that multiple files can be formatted in parallel

- Mess with D

dstyle will initially target C and will hopefully then move on to supporting additional languages.

## Components

### Scanner

The scanner will consist of a collection of objects, with one object representing a state machine
for each possible token.
The state machines will be reset at the start of each token, then fall out as we progress character by character
until a token is reached.

### Parser

The parser will initially be a shift-reduce parser. Details are TBD.

### AST

Once the parser has built the AST, the nodes' overridden `format` methods will,
based on the options and config specified by the user, format each code construct.
Name analysis, type checking, and so on can be skipped
(dstyle will make large assumptions that the user's code is correct and try to work with what it's given).

## License

See `LICENSE.md`

## Am I having déjà vu? What about [cstyle](https://github.com/slavik262/cstyle)?

1. The author started reading about D.
2. The author thought D was awesome.
3. The author decided to port what he had of cstyle to D and continue writing it in D because D is awesome.

**Related:** Can the author actually finish something instead of spinning his wheels in new technologies?

The author hopes so, but in the meantime he's learning a lot.

## Retrospective, July 2020

Writing parsers for actual languages is a lot of work,
but building ASTs is a bunch of fun, as is metaprogramming in D.
