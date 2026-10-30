# frozen_string_literal: true

require "spec_helper"

require "rubocop/katalyst/prettier_task"
require "tmpdir"

RSpec.describe RuboCop::Katalyst::PrettierTask do
  subject(:task) { described_class.new(verbose: false) }

  let(:dir) { Dir.mktmpdir }

  before { task.instance_variable_set(:@root, File.join(dir, "spec", "dummy")) }

  after { FileUtils.remove_entry(dir) }

  def write_package_json(relative_dir, json)
    path = File.join(dir, relative_dir, "package.json")
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, JSON.generate(json))
  end

  describe "#prettier_declared?" do
    it "is false without a package.json" do
      expect(task.send(:prettier_declared?)).to be(false)
    end

    it "is false when the nearest package.json does not declare prettier" do
      write_package_json(".", devDependencies: { rollup: "^4.0.0" })

      expect(task.send(:prettier_declared?)).to be(false)
    end

    it "finds prettier in an ancestor's devDependencies" do
      write_package_json(".", devDependencies: { prettier: "^3.9.10" })

      expect(task.send(:prettier_declared?)).to be(true)
    end

    it "finds prettier in the working directory's dependencies" do
      write_package_json("spec/dummy", dependencies: { prettier: "^3.9.10" })

      expect(task.send(:prettier_declared?)).to be(true)
    end

    it "stops at the nearest package.json" do
      write_package_json(".", devDependencies: { prettier: "^3.9.10" })
      write_package_json("spec/dummy", {})

      expect(task.send(:prettier_declared?)).to be(false)
    end
  end
end
