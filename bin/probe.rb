#!/usr/bin/env ruby

require "bundler/setup"

lib = File.expand_path("../lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "biblioprobe/cli"

Biblioprobe::CLI.run(ARGV)
