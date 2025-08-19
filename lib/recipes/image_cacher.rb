# frozen_string_literal: true

require "open-uri"
require "digest"
require "fileutils"
require "stringio"

module Recipes
  class ImageCacher
    # Downloads an image from recipe.image_url and saves it locally.
    # Updates recipe.image_path with the local relative path.
    #
    # Idempotent: if file already exists, it won't be downloaded again.
    # Validates content-type, size, and scheme (http/https only).
    def initialize(recipe)
      @recipe = recipe
    end

    def cache!(dry_run: false, max_size_mb: 5)
      url = @recipe.image_url
      return result(:skipped, "no image_url") if url.blank?

      unless url.match?(/\Ahttps?:\/\//i)
        return result(:skipped, "unsupported scheme")
      end

      io, meta = download_with_retries(url, max_size_mb:)
      return result(:error, meta[:error]) if io.nil?

      bytes = io.read
      digest = Digest::SHA256.hexdigest(bytes)
      ext    = detect_extension(meta[:content_type], bytes)
      return result(:skipped, "unknown extension") unless ext

      relative = File.join("/uploads/recipes", @recipe.id.to_s, "#{digest}.#{ext}")
      absolute = Rails.root.join("public", relative.delete_prefix("/"))

      FileUtils.mkdir_p(File.dirname(absolute))
      File.binwrite(absolute, bytes) unless File.exist?(absolute) || dry_run

      if dry_run
        result(:ok, "dry_run #{relative}", local: relative)
      else
        @recipe.update!(image_path: relative)
        result(:ok, "saved #{relative}", local: relative)
      end
    rescue => e
      result(:error, e.message)
    end

    def already_cached?
      @recipe.image_path.present? && @recipe.image_path.start_with?("/uploads/")
    end

    private

    def detect_extension(content_type, bytes)
      case content_type&.downcase
      when "image/jpeg" then "jpg"
      when "image/png"  then "png"
      when "image/webp" then "webp"
      else
        return "jpg"  if bytes.start_with?("\xFF\xD8".b)
        return "png"  if bytes.start_with?("\x89PNG\r\n\x1A\n".b)
        return "webp" if bytes[0,12] == "RIFF".b + bytes[4,4] + "WEBP".b rescue false
        nil
      end
    end

    def download_with_retries(url, max_size_mb:)
      attempts = 0
      begin
        attempts += 1
        return download(url, max_size_mb:)
      rescue OpenURI::HTTPError, Errno::ECONNRESET, Net::OpenTimeout, Net::ReadTimeout => e
        raise e if attempts >= 3
        sleep(0.5 * attempts)
        retry
      end
    end

    def download(url, max_size_mb:)
      meta = {}
      io = URI.parse(url).open("rb", read_timeout: 5, open_timeout: 3, "User-Agent" => "FridgieBot/1.0") do |f|
        bytes = f.read
        size = bytes.bytesize.to_f / (1024 * 1024)
        return [nil, { error: "too large (#{size.round(2)} MB > #{max_size_mb} MB)" }] if size > max_size_mb
        meta[:content_type] = f.content_type
        [StringIO.new(bytes), meta]
      end
      io
    end

    def result(status, message, local: nil)
      { status:, message:, recipe_id: @recipe.id, local: }
    end
  end
end
