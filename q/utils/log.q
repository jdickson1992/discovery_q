
\d .log

/ ANSI colour codes
colors:(!) . flip(
  (`info;  "\033[0;32m");
  (`warn;  "\033[1;33m");
  (`error; "\033[1;31m");
  (`reset; "\033[0m")
  )

/ Message that the logger will print to stderr/stdout wrapping in ansi color codes
msg:{[level;msg]
    h:$[level in `error`fatal; -2; -1];
    args:(.z.p;.log.colors[level],upper[string level],.log.colors[`reset];msg);
    h " " sv {$[10=type x; x; -11h=type x; string[x]; .Q.s1 x]} each args;
 };

/ Different log levels
error:.log.msg[`error];
warn:.log.msg[`warn];
info:.log.msg[`info];

\
Usage:
  .log.info["This is a standard log message"]      / INFO  level
  .log.warn["This is a warning"]                   / WARN  level
  .log.error["This is an error!"]                  / ERROR level