FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    cups \
    cups-client \
    cups-browsed \
    printer-driver-gutenprint \
    printer-driver-escpr \
    avahi-daemon \
    dbus \
  && rm -rf /var/lib/apt/lists/*

# Guardamos un "baseline" de /etc/cups para inicializar volúmenes vacíos.
RUN mkdir -p /usr/share/cups-default/etc-cups \
  && cp -a /etc/cups/. /usr/share/cups-default/etc-cups/

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 631

ENTRYPOINT ["/entrypoint.sh"]
