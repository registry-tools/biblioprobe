require "minitest/autorun"
require "tempfile"
require "byebug"
require "json"

require_relative "cli"

class TestCLI < Minitest::Test
  def test_run
    Tempfile.create("output.json") do |output|
      Biblioprobe::CLI.run(["-o", output.path, File.join(File.dirname(__FILE__), "fixtures/npm")])

      results = JSON.parse(File.read(output.path), symbolize_names: true)
      assert_equal 2, results[:manifests].length

      for manifest in results[:manifests]
        assert_equal "npm", manifest[:ecosystem]

        if manifest[:path] == "package-lock.json"
          assert_equal "package-lock.json", manifest[:path]
          assert_equal "lockfile", manifest[:kind]
          assert_equal true, manifest[:success]
          assert_equal 37, manifest[:dependencies].length

          chalk = manifest[:dependencies].find do |d|
            d[:name] == "chalk"
          end

          assert_equal "chalk", chalk[:name]
          assert_equal "4.1.2", chalk[:requirement]
          assert_equal "runtime", chalk[:type]

          underscore = manifest[:dependencies].find do |d|
            d[:name] == "underscore"
          end

          refute_nil underscore[:git_info]
          assert_equal "github.com", underscore[:git_info][:host]
          assert_equal "jashkenas", underscore[:git_info][:namespace]
          assert_equal "underscore", underscore[:git_info][:project]
        else
          refute_nil manifest[:git_info]
          assert_equal "github.com", manifest[:git_info][:host]
          assert_equal "registry-tools-test", manifest[:git_info][:namespace]
          assert_equal "audit-cli", manifest[:git_info][:project]
          assert_equal "package.json", manifest[:path]
          assert_equal "audit-cli", manifest[:project_name]
          assert_equal "manifest", manifest[:kind]
          assert_equal true, manifest[:success]
          assert_equal 4, manifest[:dependencies].length

          chalk = manifest[:dependencies].find do |d|
            d[:name] == "chalk"
          end

          assert_equal "chalk", chalk[:name]
          assert_equal "^4.1.2", chalk[:requirement]
          assert_equal "runtime", chalk[:type]

          underscore = manifest[:dependencies].find do |d|
            d[:name] == "underscore"
          end

          refute_nil underscore[:git_info]
          assert_equal "github.com", underscore[:git_info][:host]
          assert_equal "jashkenas", underscore[:git_info][:namespace]
          assert_equal "underscore", underscore[:git_info][:project]
        end
      end
    end
  end
end
