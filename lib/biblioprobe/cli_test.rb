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
          assert_equal 36, manifest[:dependencies].length

          chalk = manifest[:dependencies].find do |d|
            d[:name] == "chalk"
          end

          assert_equal "chalk", chalk[:name]
          assert_equal "4.1.2", chalk[:requirement]
          assert_equal "runtime", chalk[:type]
        else
          assert_equal "package.json", manifest[:path]
          assert_equal "manifest", manifest[:kind]
          assert_equal true, manifest[:success]
          assert_equal 3, manifest[:dependencies].length

          chalk = manifest[:dependencies].find do |d|
            d[:name] == "chalk"
          end

          assert_equal "chalk", chalk[:name]
          assert_equal "^4.1.2", chalk[:requirement]
          assert_equal "runtime", chalk[:type]
        end
      end
    end
  end
end
