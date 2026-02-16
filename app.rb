# frozen_string_literal: true

require 'bundler/setup'
require 'trifle/docs'
require 'puma'
require_relative './lib/markdown_shortcodes'

Trifle::Docs.configure do |config|
  config.path = File.join(__dir__, 'docs')
  config.views = File.join(__dir__, 'templates')
  config.register_harvester(Trifle::Docs::Harvester::Markdown)
  config.register_harvester(Trifle::Docs::Harvester::File)
  config.cache = ENV['APP_ENV'] == 'production'
  config.sitemap_base_url = 'https://docs.trifle.io'
end

module TrifleIo
  class Docs < Trifle::Docs::App
    before do
      next if request.path_info == '/' || !request.path_info.end_with?('/')

      normalized = request.path_info.chomp('/')
      query = request.query_string.to_s.strip
      target = query.empty? ? normalized : "#{normalized}?#{query}"
      redirect target, 301
    end

    not_found do
      erb :not_found, layout: :layout, locals: {
        meta: nil,
        sitemap: Trifle::Docs.sitemap || {}
      }
    end
  end
end
