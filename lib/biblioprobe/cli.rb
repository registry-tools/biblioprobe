require "optparse"
require "json"
require "bibliothecary"

module Biblioprobe
  class CLI
    def self.run(args)
      options = {}
      OptionParser.new do |opts|
        opts.banner = "Usage: probe.rb [options] [directory]"
        opts.on("-o", "--output FILE", "Output file (default: stdout)") do |f|
          options[:output] = f
        end
        opts.on("", "--supported-manifests", "List supported manifest file name patterns") do |f|
          options[:supported_manifests] = true
        end
      end.parse!(args)

      if options[:supported_manifests]
        Bibliothecary.supported_files.each do |ecosystem, patterns|
          puts ecosystem
          puts "  #{patterns.join("\n  ")}"
        end
        return
      end

      input_dir = args[0] || "."

      results = Bibliothecary.analyse(input_dir)

      output = {
        manifests: results.map do |manifest|
          normalize_manifest(manifest)
        end,
      }

      if results.any?
        output[:vulnerabilities] = run_osv_scanner(input_dir)
      end

      output = JSON.dump(output)

      if options[:output]
        File.write(options[:output], output)
      else
        puts output
      end
    end

    def self.run_osv_scanner(input_dir)
      JSON.parse(`osv-scanner scan source -r #{input_dir} --format json`)
    end
  end
end

# From https://github.com/ecosyste-ms/parser/blob/547fef9002feabbebf58e51e9e1dd4d4a2c158bf/app/models/job.rb

def normalize_manifest(manifest)
  manifest_hash = manifest.is_a?(Hash) ? manifest.dup : manifest.to_h
  manifest_hash.transform_keys!{ |key| key == :platform ? :ecosystem : key }

  dependencies = manifest_hash[:dependencies]
  if dependencies.is_a?(Array)
    dependencies = dependencies.map do |dep|
      if dep.is_a?(Bibliothecary::Dependency)
        dependency_to_hash(dep)
      else
        dep
      end
    end
  end

  {
    ecosystem: manifest_hash[:ecosystem],
    path: manifest_hash[:path],
    dependencies: dependencies,
    kind: manifest_hash[:kind],
    success: manifest_hash[:success],
    related_paths: manifest_hash[:related_paths]
  }
end

def dependency_to_hash(dep)
  hash = {
    name: dep.name,
    requirement: dep.requirement,
    type: dep.type || "runtime",
  }

  hash[:direct] = dep.direct unless dep.direct.nil?
  hash[:integrity] = dep.integrity unless dep.integrity.nil?
  hash[:local] = dep.local unless dep.local.nil?

  hash
end
