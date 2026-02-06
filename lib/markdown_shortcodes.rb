# frozen_string_literal: true

# Adds lightweight Markdown shortcodes to avoid writing raw HTML in docs.
# Supported blocks:
# - Callout:    :::callout note "Title"\nmarkdown...\n:::
# - Signature:  :::signature signature text\nname | type | required|optional | description\n:::
# - Tabs:       :::tabs\n@tab Title\nmarkdown\n@tab Other\nmarkdown\n:::
#
# These are expanded before Redcarpet renders the Markdown, so inner content
# still benefits from Markdown parsing (lists, code fences, etc.).

require 'securerandom'

module Trifle
  module Docs
    module Harvester
      module Markdown
        module Shortcodes
          def preprocess_markdown(body)
            processed = body.dup
            processed = process_cards(processed)
            processed = process_tabs(processed)
            processed = process_signature(processed)
            processed = process_callouts(processed)
            processed
          end

          private

          def process_callouts(text)
            text.gsub(/:::callout\s+(\w+)(?:\s+"([^"]+)")?\s*\n(.*?)\n:::/m) do
              kind = Regexp.last_match(1)
              title = Regexp.last_match(2) || kind.capitalize
              inner_md = Regexp.last_match(3).strip
              inner_html = render_fragment(preprocess_inner(inner_md))

              %(<div class="callout callout-#{kind}"><p class="callout-title">#{title}</p>#{inner_html}</div>)
            end
          end

          def process_cards(text)
            text.gsub(/:::card\s+"([^"]+)"(?:\s+"([^"]+)")?(?:\s+"([^"]+)")?(?:\s+"([^"]+)")?\s*\n(.*?)\n:::/m) do
              title = Regexp.last_match(1)&.strip
              meta = Regexp.last_match(2)&.strip
              link_text = Regexp.last_match(3)&.strip
              link_url = Regexp.last_match(4)&.strip
              inner_md = Regexp.last_match(5).strip

              link_html =
                if link_url && !link_url.empty?
                  label = link_text && !link_text.empty? ? link_text : 'Docs'
                  %(<div class="doc-card-link text-xs text-gray-500"><a href="#{link_url}">#{label}</a></div>)
                else
                  ''
                end

              meta_html =
                if meta && !meta.empty?
                  %(<div class="doc-card-meta text-xs text-gray-500 font-mono">#{meta}</div>)
                else
                  ''
                end

              inner_html = render_fragment(preprocess_inner(inner_md))

              %(<div class="doc-card"><div class="doc-card-header"><div><h2 class="doc-card-title">#{title}</h2>#{meta_html}</div>#{link_html}</div><div class="doc-card-body">#{inner_html}</div></div>)
            end
          end

          def process_signature(text)
            text.gsub(/:::signature[ \t]+([^\n]+)\n(.*?)(?:\n)?:::/m) do
              signature = Regexp.last_match(1).strip
              args_block = Regexp.last_match(2)

              args = args_block.lines.map(&:strip).reject(&:empty?).map do |line|
                parts = line.split('|', 5).map(&:strip)
                next if parts.length < 4

                name = parts[0]
                type = parts[1]
                required_raw = parts[2]

                default = nil
                desc = nil
                if parts.length == 4
                  desc = parts[3]
                else
                  default = parts[3]
                  desc = parts[4]
                end

                required =
                  case required_raw.to_s.strip.downcase
                  when 'required', 'req'
                    true
                  when 'optional', 'opt'
                    false
                  else
                    nil
                  end

                default = default&.strip
                default = nil if default&.empty?

                {
                  name: name,
                  type: type,
                  required: required,
                  default: default,
                  desc: desc
                }
              end.compact

              arg_rows = args.map do |arg|
                badges = []
                badges << %(<span class="badge badge-type">#{arg[:type]}</span>) if arg[:type] && !arg[:type].empty?
                if arg[:required] == true
                  badges << '<span class="badge badge-required">Required</span>'
                elsif arg[:required] == false
                  badges << '<span class="badge badge-optional">Optional</span>'
                end
                if arg[:default]
                  badges << %(<span class="badge badge-default">Default: #{arg[:default]}</span>)
                end
                desc_html = render_fragment(preprocess_inner(arg[:desc].to_s))
                %(<div class="arg-row"><dt><code>#{arg[:name]}</code> #{badges.join(' ')}</dt><dd>#{desc_html}</dd></div>)
              end.join

              args_html = arg_rows.empty? ? '' : %(<dl class="arg-list">#{arg_rows}</dl>)

              %(<div class="method-card"><div class="method-card-title">Signature</div><div class="method-card-signature"><code>#{signature}</code></div>#{args_html}</div>)
            end
          end

          def process_tabs(text)
            text.gsub(/:::tabs\s*\n(.*?)\n:::/m) do
              tabs_block = Regexp.last_match(1)
              tabs = []
              current = nil
              tabs_block.lines.each do |line|
                if line =~ /^@tab\s+(.+)$/
                  tabs << { title: Regexp.last_match(1).strip, body: String.new }
                  current = tabs.last
                  next
                end
                current[:body] << line if current
              end

              next Regexp.last_match(0) if tabs.empty?

              group = SecureRandom.hex(4)
              initial = "#{group}-tab-0"

              options = tabs.each_with_index.map do |tab, idx|
                key = "#{group}-tab-#{idx}"
                %(<option value="#{key}" #{idx.zero? ? 'selected' : ''}>#{tab[:title]}</option>)
              end.join

              buttons = tabs.each_with_index.map do |tab, idx|
                key = "#{group}-tab-#{idx}"
                %(<button type="button" class="tab-link" :class="{ 'tab-link-active': tab === '#{key}' }" @click="tab = '#{key}'">#{tab[:title]}</button>)
              end.join

              panels = tabs.each_with_index.map do |tab, idx|
                key = "#{group}-tab-#{idx}"
                body = render_fragment(preprocess_inner(tab[:body].strip))
                %(<div class="tab-panel" x-show="tab === '#{key}'" x-cloak>#{body}</div>)
              end.join

              %(<div class="tab-group" x-data="{ tab: '#{initial}' }" x-cloak><div class="tab-select"><select aria-label="Select a tab" x-model="tab">#{options}</select><svg viewBox="0 0 16 16" fill="currentColor" aria-hidden="true" class="pointer-events-none"><path d="M4.22 6.22a.75.75 0 0 1 1.06 0L8 8.94l2.72-2.72a.75.75 0 1 1 1.06 1.06l-3.25 3.25a.75.75 0 0 1-1.06 0L4.22 7.28a.75.75 0 0 1 0-1.06Z" clip-rule="evenodd" fill-rule="evenodd" /></svg></div><div class="tab-nav"><nav class="tab-nav-links" aria-label="Tabs">#{buttons}</nav></div>#{panels}</div>)
            end
          end

          def render_fragment(markdown)
            html = markdown_renderer.render(markdown).strip
            if html.start_with?('<p>') && html.end_with?('</p>')
              html = html.sub(/\A<p>/, '').sub(%r{</p>\z}, '')
            end
            html
          end

          def preprocess_inner(markdown)
            processed = markdown.dup
            processed = process_tabs(processed)
            processed = process_signature(processed)
            processed = process_callouts(processed)
            processed
          end
        end

        # Prepend the shortcode processing into the Markdown conveyor.
        class Conveyor
          prepend Shortcodes

          def markdown_renderer
            @markdown_renderer ||= Redcarpet::Markdown.new(
              Render.new(with_toc_data: true),
              fenced_code_blocks: true,
              disable_indented_code_blocks: true,
              footnotes: true,
              tables: true
            )
          end

          def toc_renderer
            @toc_renderer ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML_TOC)
          end

          def content
            @content = nil unless cache

            @content ||= markdown_renderer.render(
              preprocess_markdown(data.sub(/^---(.*?)---(\s*)/m, ''))
            )
          rescue StandardError => e
            puts "Markdown: Failed to parse CONTENT for #{file}: #{e}"
          end

          def toc
            @toc = nil unless cache

            @toc ||= toc_renderer.render(
              preprocess_markdown(data.sub(/^---(.*?)---(\s*)/m, ''))
            )
          rescue StandardError => e
            puts "Markdown: Failed to parse TOC for #{file}: #{e}"
          end
        end
      end
    end
  end
end
