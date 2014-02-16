import std.stdio;
import log;

void main(string[] args)
{
	startLogger();
	logLevel = LogLevel.DEBUG;
	assert(loggerRunning);
	logInfo("Beautifier in progress");
}
