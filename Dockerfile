FROM debian:bullseye

# Update and install dependencies
RUN apt-get update && apt-get install -y \
    dovecot-core dovecot-imapd dovecot-pop3d \
    && apt-get clean

# Create necessary directories
RUN mkdir -p /etc/dovecot /var/mail/vhosts

# Copy configuration files
COPY dovecot.conf /etc/dovecot/dovecot.conf
COPY 10-mail.conf /etc/dovecot/conf.d/10-mail.conf

# Expose necessary ports
EXPOSE 143 993

# Start Dovecot
CMD ["dovecot", "-F"]
