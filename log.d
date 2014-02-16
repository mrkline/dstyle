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
	STOP
}

private struct Logger {

	LogLevel level;

	this(LogLevel l = LogLevel.INFO)
	{
		level = l;
	}

	void log(LogLevel l, lazy string message, string file = __FILE__, int line = __LINE__)
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
			(OwnerTerminated o) { run = false; },
			(LoggerCommand command, Tid querier) {
				final switch(command) {
					case LoggerCommand.GET_LEVEL:
						querier.send(theLogger.level);
						break;
					case LoggerCommand.STOP:
						run = false;
						querier.send(command);
						break;
				}
			}
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

void stopLogger()
{
	Tid loggerThread = locate(loggerThreadName);
	enforce(loggerThread != Tid.init, "The logger is not running.");
	loggerThread.send(LoggerCommand.STOP, thisTid);
	enforce(receiveOnly!LoggerCommand() == LoggerCommand.STOP, "Stop command got an unexpected response");
}

@property bool loggerRunning() { return locate(loggerThreadName) != Tid.init; }

void log(LogLevel l)(lazy string message, string file = __FILE__, int line = __LINE__)
{
	Tid loggerThread = locate(loggerThreadName);
	enforce(loggerThread != Tid.init, "Logger is not running");
	loggerThread.send(l, message, file, line);
}

alias log!(LogLevel.ERROR) logError;
alias log!(LogLevel.WARN) logWarn;
alias log!(LogLevel.INFO) logInfo;
alias log!(LogLevel.DEBUG) logDebug;

@property void logLevel(LogLevel l)
{
	Tid loggerThread = locate(loggerThreadName);
	enforce(loggerThread != Tid.init, "Logger is not running");
	loggerThread.send(l);
}

@property LogLevel logLevel()
{
	Tid loggerThread = locate(loggerThreadName);
	enforce(loggerThread != Tid.init, "Logger is not running");
	loggerThread.send(LoggerCommand.GET_LEVEL, thisTid);
	return receiveOnly!LogLevel();
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
