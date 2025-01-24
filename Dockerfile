# Use Debian Bullseye as the base image
FROM debian:bullseye

# Environment variables to reduce interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Update package list and install necessary packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    dovecot-core dovecot-imapd dovecot-pop3d postfix \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create necessary directories for mail storage
RUN mkdir -p /mail/vhosts

# Copy Dovecot configuration files
COPY dovecot.conf /etc/dovecot/dovecot.conf
COPY conf.d/10-master.conf /etc/dovecot/conf.d/10-master.conf

# Copy Postfix configuration files
COPY postfix/main.cf /etc/postfix/main.cf

# Set ownership and permissions
RUN chown -R 5000:5000 /mail

# Expose necessary ports
EXPOSE 143 993 25

# Start both Postfix and Dovecot in the foreground
CMD service postfix start && dovecot -F



