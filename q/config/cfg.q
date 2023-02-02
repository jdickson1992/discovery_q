\d .cfg

/ discovery host port details - static for now
discovery.port:9090
discovery.handle:`$":",(string .z.h),":",string[discovery.port];
discovery.errorPeriod:0D00:01:30;
discovery.warnPeriod:0D00:00:30;