require 'flameboyant/version'
require 'ruby-prof-flamegraph'
require 'uri'

# rubocop:disable all
module Flameboyant
  module_function

  # ensure directory exists
  GRAPHER = File.join(__dir__, 'flamegraph.pl')

  def profile(name: nil, width: 1920, &block)
    base_name = "#{name}_#{timestamp}"

    block_result = nil
    log 'starting profile'
    result = RubyProf.profile do
      block_result = block.call
    end

    # print a graph profile to text
    printer = RubyProf::FlameGraphPrinter.new(result)

    FileUtils.mkdir_p(dest_dir)

    dst_data = dest_dir.join("#{base_name}.txt")
    dst_svg = dest_dir.join("#{base_name}.svg")
    dst_html = dest_dir.join("#{base_name}.html")

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
    # write html contents
    File.open(dst_html, 'w') {|f| f << create_html_page(dst_svg)}
    log "created: #{dst_html} <⌘ - Click> to open in your browser."

    # return original results
    block_result
  end

  def create_html_page(dst_svg)
    basename = File.basename(dst_svg)
    <<-HTML
<!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="initial-scale=1">
    <title>Flame: #{basename}</title>

    <style type="text/css">
      html, body {
        padding: 0;
        margin: 0;
      }

      .full-width {
        max-width: 100%;
        width: 100%;
        height: auto;
      }
    </style>
  </head>
  <body>
  <object class="full-width" type="image/svg+xml" data="#{URI.encode(basename)}">Your browser does not support SVGs</object>
  </body>
</html>
    HTML
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
