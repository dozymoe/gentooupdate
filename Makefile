.PHONY: fetch update update_with_kernel update_misc

all:
	@echo 'make targets: fetch, update, update_with_kernel, update_misc'

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

flags/portage-fetch: flags/portage-update flags/layman-sync /etc/portage/make.conf | flags/eix-update
	emerge -fuDN --with-bdeps=y @world && touch flags/portage-fetch

flags/build-tools-upgrade: flags/portage-fetch
	python bin/build_devel && touch flags/build-tools-upgrade

flags/kernel-upgrade: flags/portage-fetch /usr/bin/eix /usr/bin/equery flags/build-tools-upgrade
	python bin/kernel_cleanup && touch flags/kernel-upgrade	

flags/portage-upgrade: flags/portage-fetch flags/build-tools-upgrade
	-emerge -c
	emerge -uDN --quiet-build=y --with-bdeps=y @world && emerge @module-rebuild @x11-module-rebuild && touch flags/portage-upgrade

flags/portage-clean: flags/portage-upgrade
	emerge -c && touch flags/portage-clean

flags/revdep-rebuild: flags/portage-clean
	emerge @preserved-rebuild && revdep-rebuild && touch flags/revdep-rebuild

flags/portage-upgrade-full: flags/portage-upgrade | flags/portage-clean flags/revdep-rebuild
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
