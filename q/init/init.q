args:.Q.def[`service`heartbeat!(`;0b)] .Q.opt .z.x;
q_source:hsym `$system"pwd";
filepaths:string .Q.dd'[first q_source;(`config;`utils;`discover)];

.init.load:{[lib]
  -1"Loading in directory: ",lib;
  @[system;"l ",lib;{"Cant load in directory ",x,". Received error: ",y}[lib]]
 };

.init.load each 1_' filepaths;


$[`discovery ~ args`service;
  [.log.info["Turning on discovery service"];
   .log.info["Discovery service will run on port ",string[.cfg.discovery.port]];
   if[0 = system"p";
      @[system;"p ",string[.cfg.discovery.port];{.log.warn["Couldn't set port on master server: ",x]}]
   ];
   .log.info["Overriding event handlers for master process"];
   .z.po:.master.po;
   .z.pc:.master.pc;
   .cron.add[`funcName`inputs`nextRun`interval`repeat!(`.master.run;`;.z.P+00:00:01;2;1b)];
   .cron.add[`funcName`inputs`nextRun`interval`repeat!(`.master.archive;`;.z.P+00:05;5*3600;1b)];
   .cron.on[]
  ];
   /.log.info["Overriding event handlers for client process"];
   args`heartbeat;
    [
     .log.info["Service ",string[args`service]," wants to log heartbeats..."];
     .client.sendHB:1b;
     .z.pc:.client.close;
     .cron.add[`funcName`inputs`nextRun`interval`repeat!(`.client.run;`;.z.P+00:00:01;2;1b)];
     .cron.on[]
    ]]



/ Usage
/ q init/init.q -service discovery -heartbeat 0
/ q init/init.q -service rdb -heartbeat 1       
/ 