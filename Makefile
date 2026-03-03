.PHONY: docker
docker:
	docker build -t biblioprobe .

test:
	bundle exec ruby lib/biblioprobe/cli_test.rb
