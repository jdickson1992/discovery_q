\d .client

hdl:0Ni;
counter:0;                              / track how many heartbeats have been sent
//sendHB:0b;                              / toggle switch to determine if we want to send heartbeats
proc:`$"_" sv string[first[1?`4],.z.i]; / randomly set process name for now
publishInterval:0D00:00:30;             / publish heartbeat every 30s 

/ connect to discover master process
/ relies on discovery host:port details to be in cfg
connect:{ 
  conn:`;
  if[not `.cfg.discovery.handle ~ key[`.cfg.discovery.handle];
     .log.error"No discovery handle specified in config file"
  ];
  h:@[hopen;(.cfg.discovery.handle;1000);{.log.warn"Disconnected from discovery service";: 0Ni}];
  if[not null h;.log.info"Connected to discovery";hdl::h];
 };

/ close handle and set it to be a null int
disconnect:{ 
  @[hclose;hdl;()]; hdl::0Ni
 };

/ asynchronously pubs details to discovery service
/ increments hb count by 1 each time
publish:{
  payload:`process`ip`address`pid`qVersion`counter`lastHb!(proc;`$"."sv string "i"$0x00 vs .z.a;`$":",(string .z.h),":",string system"p";.z.i;`$"v" sv string .z.K,.z.k;counter;.z.t);
  .log.info["Publishing heartbeat to master server"];
  neg[hdl](`.master.storeHb;payload);
  counter+::1 
 };

/ when connection is closed, execute .client.disconnect
close:{
  if[x=hdl; 
     disconnect[]
  ]
 };

/ if disconnected, attempts to reconnect on next timer cycle
/ if handle is active, it will publish heartbeats to master process
run:{
  if[(null hdl)|(not hdl in key[.z.W]);
     .log.warn"Attempting reconnection to discovery";
     connect[]
  ];
  if[sendHB and not null hdl; 
     publish[]
  ]
 };