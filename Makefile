.PHONY: fetch update update_with_kernel update_misc

all:
	@echo 'make targets: fetch, update, update_with_kernel, update_server, update_local, update_misc'

fetch: flags/portage-fetch
	

update: flags/portage-upgrade-full
	

update_with_kernel: flags/kernel-upgrade | update
	

update_misc: flags/nodejs-upgrade flags/pip-upgrade flags/rubygem-upgrade
	

flags/system-upgrade:
	touch flags/system-upgrade
/usr/portage/metadata/timestamp: flags/system-upgrade
	emerge --sync
/usr/bin/layman:
	emerge layman
flags/layman-sync: flags/system-upgrade /usr/bin/layman
	layman --sync-all && touch flags/layman-sync
/usr/bin/eix:
	emerge eix
/usr/bin/equery:
	emerge gentoolkit
flags/eix-update: /usr/portage/metadata/timestamp flags/layman-sync /usr/bin/eix
	eix-update && touch flags/eix-update
flags/portage-update: /usr/portage/metadata/timestamp
	emerge -uN portage && touch flags/portage-update
flags/portage-fetch: flags/portage-update /usr/portage/metadata/timestamp flags/layman-sync flags/eix-update /etc/portage/make.conf
	emerge -fuDN --with-bdeps=y @world && touch flags/portage-fetch
flags/kernel-upgrade: flags/portage-fetch /usr/bin/eix /usr/bin/equery
	python bin/kernel_cleanup && touch flags/kernel-upgrade	
flags/portage-upgrade: flags/portage-fetch /etc/portage/make.conf
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
