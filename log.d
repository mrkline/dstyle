import std.stdio;
import std.exception;
import std.conv;
import std.concurrency;
import std.variant;

@trusted:

enum LogLevel {
	NONE,
	ERROR,
	WARN,
	INFO,
	DEBUG,
}

private enum LoggerCommand {
	GET_LEVEL,
	STOP,
	FLUSH_CACHE,
	CLEAR_CACHE
}

private struct Logger {

	LogLevel level;

	string[string] caches;

	this(LogLevel l = LogLevel.INFO)
	{
		level = l;
	}

	void log(LogLevel l, lazy string message, string file = __FILE__, int line = __LINE__)
	{
		if(l > level)
			return;

		writeln(l.to!string, ": ", message, " (", file, ":", line.to!string, ")");
	}

	void logCache(LogLevel l, string cache, lazy string message, string file = __FILE__, int line = __LINE__)
	{
		if (l > level)
			return;

		caches[cache] ~= l.to!string ~ ": " ~ message ~ " (" ~ file ~ ":" ~ line.to!string ~ ")\n";
	}

	void flushCache(string cache)
	{
		string* c = cache in caches;

		if(c == null) // If the cache doesn't exist, there's nothing in it, right?
			return;

		write(*c);
		// Do we want to remove the cache, or just clear it?
		caches.remove(cache);
	}

	// Do we want to remove the cache, or just clear it?
	void clearCache(string cache)
	{
		enforce(cache in caches, "No such cache exists.");
		caches.remove(cache);
	}
}

private string loggerThreadName = "logger_thread";

private void logLoop()
{
	try {
		// If we have lots of messages to process at once, we're probably stuck in a loop or something.
		// We shouldn't be logging _that_ much.
		setMaxMailboxSize(thisTid, 100, OnCrowding.throwException);

		Logger theLogger;

		// TDOO: Actually log everything even if we get an OOB
		bool run = true;
		while (run) {
			receive(
				(LogLevel l) { theLogger.level = l; },

				(LogLevel l, lazy string msg, string f, int n) { theLogger.log(l, msg, f, n); },

				(LogLevel l, string cache, lazy string msg, string f, int n) { theLogger.logCache(l, cache, msg, f, n); },

				(OwnerTerminated o) { run = false; },

				(LoggerCommand command, Tid querier) {
					switch(command) {
						case LoggerCommand.GET_LEVEL:
							querier.send(theLogger.level);
							break;
						case LoggerCommand.STOP:
							run = false;
							querier.send(command);
							break;

						default:
							// What? Bail
							assert(0);
					}
				},

				(LoggerCommand command, Tid querier, string cache) {
					switch(command) {
						case LoggerCommand.FLUSH_CACHE:
							theLogger.flushCache(cache);
							querier.send(command); // Synchronize on flush
							break;

						case LoggerCommand.CLEAR_CACHE:
							theLogger.clearCache(cache);
							break;

						default:
							// What? Bail
							assert(0);
					}
				}
			);
		}
	}
	catch (Exception ex) {
		stderr.writeln("Logger died with:\n" ~ ex.to!string);
	}
}

void startLogger()
{
	enforce(locate(loggerThreadName) == Tid.init, "The logger has already been started.");
	Tid startedLogger = spawn(&logLoop);
	assert(startedLogger != Tid.init);
	register(loggerThreadName, startedLogger);
}

void stopLogger()
{
	Tid loggerThread = enforceRunning();
	loggerThread.send(LoggerCommand.STOP, thisTid);
	enforce(receiveOnly!LoggerCommand() == LoggerCommand.STOP, "Stop command got an unexpected response");
}

@property bool loggerRunning() { return locate(loggerThreadName) != Tid.init; }

void log(LogLevel l)(lazy string message, string file = __FILE__, int line = __LINE__)
{
	Tid loggerThread = enforceRunning();
	loggerThread.send(l, message, file, line);
}

alias log!(LogLevel.ERROR) logError;
alias log!(LogLevel.WARN) logWarn;
alias log!(LogLevel.INFO) logInfo;
alias log!(LogLevel.DEBUG) logDebug;

void logCache(LogLevel l)(string cache, lazy string message, string file = __FILE__, int line = __LINE__)
{
	Tid loggerThread = enforceRunning();
	loggerThread.send(l, cache, message, file, line);
}

alias logCache!(LogLevel.ERROR) logCacheError;
alias logCache!(LogLevel.WARN) logCacheWarn;
alias logCache!(LogLevel.INFO) logCacheInfo;
alias logCache!(LogLevel.DEBUG) logCacheDebug;

void logCacheFlush(string cache)
{
	Tid loggerThread = enforceRunning();
	loggerThread.send(LoggerCommand.FLUSH_CACHE, thisTid, cache);
	// Synchronize on flush
	enforce(receiveOnly!LoggerCommand() == LoggerCommand.FLUSH_CACHE, "Flush got unexpected ackknowledgement");
}

void logCacheClear(string cache)
{
	Tid loggerThread = enforceRunning();
	loggerThread.send(LoggerCommand.CLEAR_CACHE, thisTid, cache);
}

@property void logLevel(LogLevel l)
{
	Tid loggerThread = enforceRunning();
	loggerThread.send(l);
}

@property LogLevel logLevel()
{
	Tid loggerThread = enforceRunning();
	loggerThread.send(LoggerCommand.GET_LEVEL, thisTid);
	return receiveOnly!LogLevel();
}

private Tid enforceRunning()
{
	Tid loggerThread = locate(loggerThreadName);
	enforce(loggerThread != Tid.init, "Logger is not running");
	return loggerThread;
}

unittest {
	assert(!loggerRunning);
	startLogger();
	assert(loggerRunning);
	logLevel = LogLevel.DEBUG;
	assert(logLevel == LogLevel.DEBUG);
	stopLogger();
	assert(!loggerRunning);
}
