import std.stdio;
import log;

void main(string[] args)
{
	startLogger();
	setLevel(LogLevel.DEBUG);
	logInfo("Beautifier in progress");
}
