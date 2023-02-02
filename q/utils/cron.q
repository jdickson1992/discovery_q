\d .cron

/ Create a table to track cron jobs
jobs:1!flip `id`function`args`nextRun`interval`repeat!"JS*PJB"$\:();

/ Delete cron job by function name
deleteJobByFunc:{[func]
    .log.info"deleting function ",string[func]," from timer";
    delete from `.cron.jobs where function=func;
  };

/ Delete cron job by id
deleteJobByID:{[ID]
    .log.info"deleting timer ID ",string[ID]," from timer";
    delete from `.cron.jobs where id=ID;
  };

/ Execute cron job and update next run time if job set to repeat
run:{[i]
    jobToRun:.cron.jobs[i];
    func:value jobToRun[`function];
    $[1=count jobToRun[`args];
        @[func;jobToRun[`args];{.log.error"Failed to run with error: ",x} ];
        .[func;jobToRun[`args];{.log.error"Failed to run with error: ",x} ]
    ];
    / If Job is set to repeat, update next run time
    .cron.jobs:$[jobToRun[`repeat];
      update nextRun:.z.P+interval*`long$1e9 from .cron.jobs;
      delete from .cron.jobs where id=i
    ];
  };

/ Add job to cron
add:{[args]
  .log.info "Adding job with the following details:";
  show args;
  `.cron.jobs upsert(
    1+count .cron.jobs;
    args`funcName; 
    args`inputs;
    args`nextRun;
    args`interval;
    args`repeat
  );
  };

/ Overwrite the .z.ts event handler to check and execute any cron jobs
.z.ts:{[]
    ids:exec id from .cron.jobs where nextRun<.z.P;
    .cron.run each ids;
  };

/ Turn on cron
.cron.on:{
  .log.info["Enabling cron timer"];
  system "t 100"
 };

/ Turn off cron
.cron.off:{
  .log.info["Disabling cron timer"];
  system "t 0"
 };


\
Usage:
  f:{show x+y};
  g:{show x-y};
  .cron.add[`funcName`inputs`nextRun`interval`repeat!(`f;4 5;.z.P+00:00:10;5;1b)]        / run in 10s and then proceed to run every 5 seconds
  .cron.add[`funcName`inputs`nextRun`interval`repeat!(`g;4 5;.z.P+00:00:10;1*3600;1b)]   / run in 10s and then proceed to run every hour
