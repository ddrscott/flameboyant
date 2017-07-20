require 'flameboyant/version'
require 'ruby-prof-flamegraph'

# rubocop:disable all
module Flameboyant
  module_function

  # ensure directory exists
  GRAPHER = File.join(__dir__, 'flamegraph.pl')

  def profile(name: nil, width: 1920, &block)
    name = "#{name}_#{timestamp}"

    RubyProf::FlameGraphPrinter

    block_result = nil
    log 'starting profile'
    result = RubyProf.profile do
      block_result = block.call
    end

    # print a graph profile to text
    printer = RubyProf::FlameGraphPrinter.new(result)

    FileUtils.mkdir_p(dest_dir)

    dst_data = dest_dir.join("#{name}.txt")
    dst_svg = dest_dir.join("#{name}.svg")

    log "writing: #{dst_data}"
    File.open(dst_data, 'w') do |f|
      printer.print(f, {})
    end

    log 'generating SVG'
    if system("#{GRAPHER} --countname=ms --width=#{width} #{dst_data} > #{dst_svg}")
      log "created: #{dst_svg}"
      log "removing: #{dst_data}"
      FileUtils.rm(dst_data)
    end
    block_result
  end

  def dest_dir
    if defined? Rails
      Rails.root.join('tmp', 'flames')
    else
      Dir.pwd
    end
  end

  def timestamp
    '%.04f' % Time.now.to_f
  end

  def log(msg)
    full_msg = "[flame] #{msg}"
    Rails.logger.info full_msg if defined? Rails
    $stderr.puts full_msg
  end
end
