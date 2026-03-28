RUBY_VERSION := $(shell cat .ruby-version)

.PHONY: docker
docker:
	docker build --build-arg RUBY_VERSION=$(RUBY_VERSION) -t biblioprobe .

test:
	bundle exec ruby lib/biblioprobe/cli_test.rb
