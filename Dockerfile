# Use Debian Bullseye as the base image
FROM debian:bullseye

# Set non-interactive mode for package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install necessary packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    dovecot-core dovecot-imapd dovecot-pop3d postfix supervisor \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create necessary directories for mail storage and configuration
RUN mkdir -p /mail/vhosts /var/log/supervisor

# Copy Dovecot configuration files
COPY dovecot.conf /etc/dovecot/dovecot.conf
COPY conf.d/10-master.conf /etc/dovecot/conf.d/10-master.conf

# Copy Postfix configuration files
COPY postfix/main.cf /etc/postfix/main.cf

# Copy startup script
COPY start-services.sh /start-services.sh
RUN chmod +x /start-services.sh

# Expose necessary ports
EXPOSE 143 993 25

# Set the startup command to run both Postfix and Dovecot
CMD ["/start-services.sh"]



