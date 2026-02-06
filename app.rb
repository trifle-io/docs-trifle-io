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
end

module TrifleIo
  class Docs < Trifle::Docs::App
    not_found do
      erb :not_found, layout: :layout, locals: {
        meta: nil,
        sitemap: Trifle::Docs.sitemap || {}
      }
    end
  end
end
