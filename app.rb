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
    set :root, __dir__
    set :static, true
    set :public_folder, File.join(root, 'public')

    LEGACY_REDIRECTS = {
      '/blog' => 'https://trifle.io/blog',
      '/site.webmanifest' => '/favicon_dark/site.webmanifest',
      '/trifle-stats-rb/transponders/average' => '/trifle-stats-rb/transponders',
      '/trifle-stats-rb/transponders/standard_deviation' => '/trifle-stats-rb/transponders'
    }.freeze

    before do
      normalized = request.path_info == '/' ? '/' : request.path_info.chomp('/')
      target = LEGACY_REDIRECTS[normalized]
      if target
        query = request.query_string.to_s.strip
        target = "#{target}?#{query}" unless query.empty?
        redirect target, 301
      end

      next if normalized == request.path_info

      query = request.query_string.to_s.strip
      target = query.empty? ? normalized : "#{normalized}?#{query}"
      redirect target, 301
    end

    after do
      next unless response.status == 200 && markdown_requested?(request, params)

      canonical_path = request.path_info == '/' ? '/' : request.path_info.chomp('/')
      headers['Link'] = %(<https://docs.trifle.io#{canonical_path}>; rel="canonical")
    end

    not_found do
      erb :not_found, layout: :layout, locals: {
        meta: nil,
        sitemap: Trifle::Docs.sitemap || {}
      }
    end
  end
end
