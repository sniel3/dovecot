#!/bin/bash

# Start Postfix in foreground mode
/usr/sbin/postfix start-fg &

# Start Dovecot in foreground mode
/usr/sbin/dovecot -F

