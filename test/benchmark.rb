# frozen_string_literal: true

require "benchmark/ips"
require "commonmarker"
require "markly"
require "kramdown"
require "kramdown-parser-gfm"
require "redcarpet"
require "benchmark"

small = File.read("test/benchmark/small.md").freeze
large = File.read("test/benchmark/large.md").freeze

[small, large].each do |input|
  printf("input size = %<bytes>d bytes\n\n", { bytes: input.bytesize })

  Benchmark.ips do |x|
    x.report("Markly.render_html") do
      Markly.render_html(input)
    end

    x.report("Markly::Node#to_html") do
      Markly.parse(input).to_html
    end

    x.report("Redcarpet::Markdown#render") do
      renderer = Redcarpet::Render::HTML.new(with_toc_data: true, hard_wrap: true, gh_blockcode: true, xhtml: true)
      Redcarpet::Markdown.new(renderer, fenced_code_blocks: true, no_intra_emphasis: true, tables: true, autolink: true, strikethrough: true, space_after_headers: true).render(input)
    end

    x.report("Commonmarker.to_html") do
      Commonmarker.to_html(input)
    end

    x.report("Commonmarker::Node.to_html") do
      Commonmarker.parse(large).to_html
    end

    x.report("Kramdown::Document#to_html") do
      Kramdown::Document.new(input, input: "GFM").to_html
    end

    x.compare!
  end
end
