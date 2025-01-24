# Use Debian as the base image
FROM debian:bullseye

# Install Dovecot and Postfix
RUN apt-get update && apt-get install -y \
    dovecot-core dovecot-imapd dovecot-pop3d postfix \
    && apt-get clean

# Create necessary directories
RUN mkdir -p /etc/dovecot /var/mail/vhosts

# Copy Dovecot configuration files
COPY dovecot.conf /etc/dovecot/dovecot.conf
COPY conf.d/10-master.conf /etc/dovecot/conf.d/10-master.conf

# Copy Postfix configuration files
COPY postfix/main.cf /etc/postfix/main.cf

# Expose IMAP and SMTP ports
EXPOSE 143 993 25

# Start Dovecot and Postfix
CMD service postfix start && dovecot -F

# Add mail storage and user credentials
COPY mail /mail
COPY users /etc/dovecot/users

# Ensure proper permissions
RUN chown -R 5000:5000 /mail

