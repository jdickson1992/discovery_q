\d .master

/ table schemas
.master.clients:2!flip `proc`h`active`user`host`port`ip`pid`to`tc!"sibssisipp"$\:();
.master.discovery:1!flip `process`handle`ip`address`pid`counter`lastHb`active`warning`error!"sis*iitbbb"$\:();

/ overrides the port open event handler
/ keeps track of clients who connect to the master process
po:{ 
  $[null .[{x y};(x;`.client.proc);{::}];
    p:`undef;
    p:x`.client.proc];
    `.master.clients upsert(p;x;1b;.z.u;.z.h;x"\\p";`$"."sv string "i"$0x00 vs .z.a;x`.z.i;.z.P;0Np)
 };

/ overrides the port close event handler
/ removes client from tracking table
pc:{
  if[not[null inactive] and count inactive:first exec process from .master.discovery where handle=x;
     update handle:0Ni, active:0b from `.master.discovery where process=inactive];
     .log.info["Deleting handle from clients table"];
     delete from `.master.clients where h=x
 };

/ heartbeats are stored in a discovery table, used for tracking
storeHb:{ 
    if[not[null expiredH] and not .z.w~expiredH:.master.discovery[x`process;`handle];
       `.master.discovery upsert @[;`active;:;0b] @[;`time;:;time] exec from status where handle=expiredH;
       @[hclose;expiredH;()]];
    payload:(x`process;.z.w;x`ip;x`address;x`pid;x`counter;x`lastHb;1b;0b;0b);
    upsert[`.master.discovery;payload]
 };

/ checks for regular heartbeats, if not updates table in memory to show alerts/warnings
/ If current time is greater than last heartbeat time + errorPeriod, fire error
/ If current time is greater than last heartbeat time + warningPeriod, fire warning
checkHb:{[x]
  proc:x`process;
  hb:.master.discovery[proc;`lastHb];
  delay:.z.T-hb;
  if[delay > 00:10;
     .log.info["Process ",string[proc]," hasnt sent a heartbeat in 10minutes. Deleting entry from .master.discovery table"];
     delete from `.master.discovery where process=proc;
     : ()
  ];
  $[hb<.z.p-.cfg.discovery.errorPeriod;
    [
    .log.error["Havent received a heartbeat from ",string[proc]," in ",string[delay],"s"];
    update error:1b,warning:0b,active:0b from `.master.discovery where process=proc
    ];
    hb<.z.p-.cfg.discovery.warnPeriod;
    [
       .log.warn["Havent received a heartbeat from ",string[proc]," in ",string[delay],"s"];
       update warning:1b from `.master.discovery where process=proc
    ]
  ]
 };

/ Clears out the tracking tables 
archive:{
  delete from `.master.discovery where null handle;
  delete from `.master.clients where proc=`undef
 };

/ ================================ WEBSOCKETS =================================== /
/ table for tracking connections
activeWSConnections:([] handle:(); connectTime:());

/ subs table to keep track of current subscriptions
subs:2!flip `handle`func`params!"is*"$\:();

/ functions to be called through WebSocket
/ called immediately upon successful handshake
/ populates webpage with discovery table immediately
loadPage:{ 
  getSyms[.z.w]; 
  sub[`.master.getDiscovery;enlist `]
 };

/ updates subs table with a distinct list of syms/process
filterSyms:{ 
  sub[`.master.getDiscovery;x]
 };

/ webpage calls this over ws to get distinct processes running in the domain
getSyms:{ 
  (neg[x]) .j.j `func`result!(`getSyms;exec distinct process from discovery)
 };

/ pulls in the discovery table
/ accepts a list of syms or ` as an arg
/ filters based on input and returns result to webpage
getDiscovery:{
  filter:$[all raze null x;distinct (key .master.discovery)`process;raze x];
  res:0!select from .master.discovery where process in filter;
  `func`result!(`getDiscovery;res)
 };

/ subscribe to something
sub:{
 `.master.subs upsert(.z.w;x;enlist y)
 };

/ publish data according to subs table
pub:{
  row:(0!subs)[x];
  (neg row[`handle]) .j.j (value row[`func])[row[`params]]
 };

/ called as a cronjob to check heartbeats for each client
run:{
  .master.checkHb'[key .master.discovery];
  .master.pub each til count subs
 };

/ open connections added to tracking table
.z.wo:{
  `.master.activeWSConnections upsert (x;.z.t)
 }

.z.wc:{
  delete from `.master.subs where handle=x
 };

.z.ws:{
  value x
 };

