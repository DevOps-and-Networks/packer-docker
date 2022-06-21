ci: clean deps lint build-docker-base

clean:
	rm -rf logs modules

init:
	mkdir -p artifacts

deps:
	gem install bundler --version=1.17.3
	bundle install -j4
	pip3 install -r requirements.txt
	docker pull centos:centos8

lint:
	yamllint \
		conf/ansible/inventory/group_vars/*.yaml \
		provisioners/ansible/playbooks/*.yaml
	puppet-lint \
		--fail-on-warnings \
		--no-documentation-check \
		provisioners/*.pp
	shellcheck \
		provisioners/*.sh

build-docker-base:
	PACKER_TMP_DIR=/tmp scripts/run-playbook-stack.sh build "${config_path}" base

publish-docker-base:
	scripts/run-playbook-stack.sh publish "${config_path}" base

release:
	rtk release

.PHONY: ci clean init deps lint build-docker-base build-docker-sandpit build-docker-publisher publish-docker-base publish-docker-sandpit publish-docker-publisher release
