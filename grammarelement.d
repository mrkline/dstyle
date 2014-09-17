
/**
 * GrammarElement originally provided a common base class
 * for Tokens and ASTNodes in order to provide a definition type for the two,
 * but now that both are identified by their ClassInfo, this is unneeded.
 * For now it will remain as a marker interface for the parser,
 * but this may be unnecessary.
 */
interface GrammarElement { }
