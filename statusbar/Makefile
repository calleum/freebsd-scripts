# SPDX-License-Identifier: BSD-3-Clause
PREFIX=/usr/local
EPREFIX=
BINDIR=$(PREFIX)/bin
DATADIR=$(PREFIX)/share/status

.PHONY: FORCE all install uninstall clean distclean maintainer-clean

all: status.sh

status.sh:
	echo '#!/bin/cat $(DATADIR)/status.sh' >status.sh

install: status.sh
	install -d '$(DESTDIR)$(BINDIR)'
	install -d '$(DESTDIR)/$(DATADIR)'
	install -m 755 status.sh '$(DESTDIR)$(BINDIR)/status.sh'
	install -m 644 bin/status.sh '$(DESTDIR)$(DATADIR)/status.sh'

uninstall: FORCE
	rm -f '$(DESTDIR)/$(BINDIR)/status.sh'
	rm -f '$(DESTDIR)/$(DATADIR)/status.sh'
	-rmdir '$(DESTDIR)/$(DATADIR)'

clean: FORCE
	rm -f ./status.sh

distclean: clean FORCE
	rm -f ./status-*.asc ./status-*.tar.* ./status-*.tar ./status-*.zip

maintainer-clean: distclean FORCE

FORCE:
