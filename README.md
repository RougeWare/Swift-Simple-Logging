# `SimpleLogging` #

A simple, cross-platform, lightweight logging framework powered by Swift's built-in features (like `print` and `FileHandle`).

This framework was built for both out-of-the-box simplicity when you just need logging, and powerful extensibility for when your enterprise app has specific logging needs.


## Examples ##

### Severities ###

Six severity levels are defined in this package, but you can define more if you please:

- 💬 `verbose` - The lowest builtin priority; anything and everything might be logged at this level
- 👩🏾‍💻 `debug` - Usually not included in user-facing logs, but helpful messages for debugging issues in the field
- ℹ️ `info` - Usually the lowest level that appears in user logs, information for power-users who look at logs
- ⚠️ `warning` - Describing potential future problems. "Future" might be the next line, the next release, etc.
- 🆘 `error` - Problems that just happened. A server log might only print lines of this severity or higher.
- 🚨 `fatal` - The only fatal lines in a log file should be the last lines, in the event of a crash

This package also pairs these with some convenient global-scope functions for quick logging:

```swift
log(verbose: "Starting...")
log(debug: "TODO: Implement startup procedure")
log(info: "Startup done")
log(warning: "Future versions won't support the `--magically-work` flag")

if username == "BenLeggiero" {
    log(error: "You aren't allowed in here")
    return
}

if system.environment.isInvalid {
    log(fatal: "Environment is invalid")
    fatalError()
}
```

Example output, with a channel which allows all messages:
```plain
2020-05-19 22:30:06.362Z 💬 Starting...
2020-05-19 22:30:06.362Z 👩🏾‍💻 TODO: Implement statup procedure
2020-05-19 22:30:06.362Z ℹ️ Startup done
2020-05-19 22:30:06.362Z ⚠️ Future versions won't support the `--magically-work` flag
2020-05-19 22:30:06.362Z 🚨 Environment is invalid
```


If you want, you can also specify these (and any you make) explicitly:

```swift
log(severity: .trace, "\(i) iterations so far")
```
```swift
log(severity: .critical, "The system is down!")
```

By default, severities are represented by emoji (like ℹ️ for `info` and 🆘 for `error`) so a human can more-easily skim a log. Each can also be represented by a plaintext character or long name (for example, `debug`'s names are 👩🏾‍💻, `"d"`, and `"debug"`). You can set this this per-channel, in case your channel can't handle UTF-16, or in case you just don't like that.


### Channels ###

By default, this just logs to the same place as Swift's `print` statement. Because enterprise apps have different needs, it can also log to `stdout`, `stderr`, and any `FileHandle`. Arbitrarily many of these can operate simultaneously. You can also specify this per-log-call or for all log calls.

**If none is specified, the lowest allowed severity is `info`**, since that's the lowest built-in severity which users might care about if they're looking at the logs, but not debugging the code itself.

```swift
LogManager.defaultChannels += [
    try LogChannel(name: "General Log File", location: .file(path: "/tmp/com.acme.AwesomeApp/general.log")),
    try LogChannel(name: "Debug Log File", location: .file(path: "/tmp/com.acme.AwesomeApp/debug.log"), lowestAllowedSeverity: .debug),
    try LogChannel(name: "Error Log File", location: .file(path: "/tmp/com.acme.AwesomeApp/errors.log"), lowestAllowedSeverity: .error, logSeverityNameStyle: .short),
]
```

In the above example, `info` and up log messages will go to Swift's `print` target, and to a general log file, whereas `error` and up log messages will go to a specific error log file (which won't contain emoji), and `debug` log messages (and up) go to a specific debug log file. All channels will receive all `error` and up log messages. For example:

```swift
log(verbose: "This is thrown away")
log(debug: "This only goes to the debug log channel")
log(info: "This goes to most of the log channels")
log(warning: "Same here")
log(error: "This is the first item in the error log; everything gets this")
log(fatal: "Everything gets this too")
```

The above lines will result in these logs:

<table><tbody>

<tr><td>
<strong>Everywhere Swift's <code>print</code> usually goes:</strong>
<pre>
2020-05-19 22:30:06.362Z ℹ️ This goes to most of the log channels
2020-05-19 22:30:06.362Z ⚠️ Same here
2020-05-19 22:30:06.362Z 🆘 This is the first item in the error log; everything gets this
2020-05-19 22:30:06.362Z 🚨 Everything gets this too
</pre>
</td></tr>

<tr><td>
<strong><code>/tmp/com.acme.AwesomeApp/general.log</code></strong>
<pre>
2020-05-19 22:30:06.362Z ℹ️ This goes to most of the log channels
2020-05-19 22:30:06.362Z ⚠️ Same here
2020-05-19 22:30:06.362Z 🆘 This is the first item in the error log; everything gets this
2020-05-19 22:30:06.362Z 🚨 Everything gets this too
</pre>
</td></tr>

<tr><td>
<strong><code>/tmp/com.acme.AwesomeApp/debug.log</code></strong>
<pre>
2020-05-19 22:30:06.362Z 👩🏾‍💻 This only goes to the debug log channel
2020-05-19 22:30:06.362Z ℹ️ This goes to most of the log channels
2020-05-19 22:30:06.362Z ⚠️ Same here
2020-05-19 22:30:06.362Z 🆘 This is the first item in the error log; everything gets this
2020-05-19 22:30:06.362Z 🚨 Everything gets this too
</pre>
</td></tr>

<tr><td>
<strong><code>/tmp/com.acme.AwesomeApp/errors.log</code></strong>
<pre>
2020-05-19 22:30:06.362Z 🆘 This is the first item in the error log; everything gets this
2020-05-19 22:30:06.362Z 🚨 Everything gets this too
</pre>
</td></tr>

</tbody></table>

### Logging scope entry/exit ###

When tracing through code in your logs, it's common to put log statements when a scope is entered and when it's exited. This framework makes such an action first-class and quite easy:

```swift
func notable() {
    logEntry(); defer { logExit() }
    
    MyApp.notableOperation()
}
```

```swift
func longAsyncOperation() {
    logEntry(); defer { logExit() }
    
    DispatchQueue.main.async {
        logEntry(); defer { logExit() }
        
        longOperation()
    }
}
```
