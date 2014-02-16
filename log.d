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

private struct Logger {

	LogLevel level;

	this(LogLevel l = LogLevel.INFO)
	{
		level = l;
	}

	void log(LogLevel l, string message, string file = __FILE__, int line = __LINE__)
	{
		if(l >= level)
			return;

		writeln(l.to!string, ": ", message, "(", file, ":", line.to!string, ")");
	}
}

private string loggerThreadName = "logger_thread";

private void logLoop()
{
	Logger theLogger;

	// TDOO: Actually log everything even if we get an OOB
	bool run = true;
	while (run) {
		receive(
			(LogLevel l) { theLogger.level = l; },
			(LogLevel l, string msg, string f, int n) { theLogger.log(l, msg, f, n); },
			(OwnerTerminated o) { run = false; }
		);
	}
}

void startLogger()
{
	enforce(locate(loggerThreadName) == Tid.init, "The logger has already been started.");
	Tid startedLogger = spawn(&logLoop);
	assert(startedLogger != Tid.init);
	register(loggerThreadName, startedLogger);
}

void log(LogLevel l)(string message, string file = __FILE__, int line = __LINE__)
{
	Tid loggerThread = locate(loggerThreadName);
	enforce(loggerThread != Tid.init, "Logger is not running");
	loggerThread.send(l, message, file, line);
}

alias log!(LogLevel.ERROR) logError;
alias log!(LogLevel.WARN) logWarn;
alias log!(LogLevel.INFO) logInfo;
alias log!(LogLevel.DEBUG) logDebug;

void setLevel(LogLevel l)
{
	Tid loggerThread = locate(loggerThreadName);
	enforce(loggerThread != Tid.init, "Logger is not running");
	loggerThread.send(l);
}
