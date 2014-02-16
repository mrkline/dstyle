import std.stdio;
import log;

void main(string[] args)
{
	startLogger();
	logLevel = LogLevel.DEBUG;
	assert(loggerRunning);
	logInfo("Beautifier in progress");
	logCacheInfo("silly", "Caching 1");
	logCacheInfo("silly", "Caching 2");
	logCacheInfo("silly", "Caching 3");
	logInfo("Sent after cache. Flushing cache");
	logCacheFlush("silly");
}
