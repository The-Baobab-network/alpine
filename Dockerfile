# https://www.linuxcontainers.dev
# Source repository: https://github.com/linuxcontainers/alpine
# Source licensed under the MIT License: https://github.com/linuxcontainers/alpine/blob/master/LICENSE
FROM alpine:3.16
LABEL maintainer="peter@linuxcontainers.dev" \
    org.opencontainers.image.authors="Peter, peter@linuxcontainers.dev, https://www.linuxcontainers.dev/" \
    org.opencontainers.image.source="https://github.com/linuxcontainers/alpine" \
    org.opencontainers.image.title="alpine" 
# Add Tailscale repository
RUN echo "https://pkgs.tailscale.com/stable/alpine/3.16/main" >> /etc/apk/repositories

# Install Tailscale and dependencies
RUN /sbin/apk update --no-cache \
    && /sbin/apk upgrade --no-cache \
    && /sbin/apk add --no-cache tailscale \
    && /bin/rm -rf /var/cache/apk/*

# Enable IP forwarding
RUN echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf \
    && echo 'net.ipv6.conf.all.forwarding = 1' >> /etc/sysctl.conf

# Create startup script
RUN echo '#!/bin/sh' > /start.sh \
    && echo 'tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock &' >> /start.sh \
    && echo 'sleep 2' >> /start.sh \
    && echo 'tailscale up --ssh' >> /start.sh \
    && chmod +x /start.sh

CMD ["/start.sh"]
