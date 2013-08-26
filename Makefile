.PHONY: fetch update_server update_local update_misc

all:
	@echo 'make targets: fetch, update_server, update_local, update_misc'

fetch: flags/portage-fetch
	

update_server: flags/portage-upgrade-full update_misc | flags/kernel-hardened-upgrade
	

update_local: flags/portage-upgrade-full update_misc | flags/kernel-pfsource-upgrade
	

update_misc: flags/nodejs-upgrade flags/pip-upgrade flags/rubygem-upgrade
	

flags/system-upgrade:
	touch flags/system-upgrade
/usr/portage/metadata/timestamp: flags/system-upgrade
	emerge --sync
/usr/bin/layman:
	emerge -j1 layman
flags/layman-sync: flags/system-upgrade /usr/bin/layman
	layman --sync-all && touch flags/layman-sync
/usr/bin/eix:
	emerge -j1 eix
flags/eix-update: /usr/portage/metadata/timestamp flags/layman-sync /usr/bin/eix
	eix-update && touch flags/eix-update
flags/portage-update: /usr/portage/metadata/timestamp
	emerge -j1 -uN portage && touch flags/portage-update
flags/portage-fetch: flags/portage-update /usr/portage/metadata/timestamp flags/layman-sync flags/eix-update /etc/portage/make.conf
	emerge -j1 -fuDN --with-bdeps=y @world && touch flags/portage-fetch
flags/kernel-pfsource-config-backup: flags/portage-fetch
	cp /usr/src/linux/.config /usr/src/kernel-pfsource-config && touch flags/kernel-pfsource-config-backup
flags/kernel-hardened-config-backup: flags/portage-fetch
	cp /usr/src/linux/.config /usr/src/kernel-hardened-config && touch flags/kernel-hardened-config-backup
flags/kernel-pfsource-upgrade: flags/kernel-pfsource-config-backup
	emerge -uN --with-bdeps=y sys-kernel/pf-sources && \
	cp /usr/src/kernel-pfsource-config /usr/src/linux/.config && \
	touch flags/kernel-pfsource-upgrade && \
	yes "" | make -C /usr/src/linux silentoldconfig && \
	make -C /usr/src/linux && \
	make -C /usr/src/linux install && \
	make -C /usr/src/linux modules_install && \
	python bin/kernel_cleanup && \
	touch flags/kernel-upgrade
flags/kernel-hardened-upgrade: flags/kernel-hardened-config-backup
	emerge -uN --with-bdeps=y sys-kernel/hardened-sources && \
	cp /usr/src/kernel-hardened-config /usr/src/linux/.config && \
	touch flags/kernel-hardened-upgrade && \
	yes "" | make -C /usr/src/linux silentoldconfig && \
	make -C /usr/src/linux && \
	make -C /usr/src/linux install && \
	make -C /usr/src/linux modules_install && \
	python bin/kernel_cleanup && \
	touch flags/kernel-upgrade
flags/kernel-upgrade:
	
flags/portage-upgrade: flags/portage-fetch flags/kernel-upgrade /etc/portage/make.conf
	emerge -uDN --with-bdeps=y @world && emerge @module-rebuild @x11-module-rebuild && touch flags/portage-upgrade
	emerge -c
flags/portage-clean: flags/portage-upgrade
	emerge -c && touch flags/portage-clean
flags/revdep-rebuild: flags/portage-clean
	emerge @preserved-rebuild && revdep-rebuild && touch flags/revdep-rebuild
flags/portage-upgrade-full: flags/portage-upgrade flags/portage-clean flags/revdep-rebuild
	touch flags/portage-upgrade-full
flags/pip-upgrade:
	#flags/python-update
	pip install --upgrade && touch flags/pip-upgrade
flags/nodejs-upgrade: flags/portage-upgrade-full
	npm update -g && touch flags/nodejs-upgrade
flags/rubygem-upgrade: flags/portage-upgrade-full
	gem update && touch flags/rubygem-upgrade
flags/python-update: flags/portage-upgrade-full
	python-updater && touch flags/python-update