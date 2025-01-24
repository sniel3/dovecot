# Base image
FROM debian:bullseye

# Install dependencies
RUN apt-get update && apt-get install -y \
    dovecot-core dovecot-imapd dovecot-pop3d \
    && apt-get clean

# Create necessary directories
# Use Debian as the base image
FROM debian:bullseye

# Update and install necessary dependencies
RUN apt-get update && apt-get install -y \
    dovecot-core dovecot-imapd dovecot-pop3d \
    && apt-get clean

# Create necessary directories
RUN mkdir -p /etc/dovecot /var/mail/vhosts

# Copy the Dovecot configuration files
COPY dovecot.conf /etc/dovecot/dovecot.conf
COPY conf.d/10-mail.conf /etc/dovecot/conf.d/10-mail.conf

# Expose necessary ports for IMAP
EXPOSE 143 993

# Start the Dovecot server in foreground mode
CMD ["dovecot", "-F"]


