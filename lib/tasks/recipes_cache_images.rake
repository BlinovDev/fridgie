# frozen_string_literal: true

namespace :recipes do
  desc "Download external images into public/uploads and update image_path"
  # Usage:
  #   bin/rails "recipes:cache_images[batch_size=100,only_missing=true,dry_run=false,max_size_mb=5]"
  task :cache_images, [:batch_size, :only_missing, :dry_run, :max_size_mb] => :environment do |_, args|
    batch_size   = (args[:batch_size] || 100).to_i
    only_missing = ActiveModel::Type::Boolean.new.cast(args[:only_missing] || "true")
    dry_run      = ActiveModel::Type::Boolean.new.cast(args[:dry_run] || "false")
    max_size_mb  = (args[:max_size_mb] || 5).to_i # probably use limit of 12MB should cover most of the cases

    puts "[recipes:cache_images] batch_size=#{batch_size} only_missing=#{only_missing} dry_run=#{dry_run} max_size_mb=#{max_size_mb}"

    total = ok = skip = err = 0

    Recipe.in_batches(of: batch_size) do |batch|
      batch.each do |recipe|
        total += 1
        cacher = Recipes::ImageCacher.new(recipe)

        if only_missing && cacher.already_cached?
          skip += 1
          puts "  - ##{recipe.id} SKIP already cached"
          next
        end

        res = cacher.cache!(dry_run:, max_size_mb:)
        case res[:status]
        when :ok
          ok += 1
          puts "  - ##{recipe.id} OK #{res[:message]}"
        when :skipped
          skip += 1
          puts "  - ##{recipe.id} SKIP #{res[:message]}"
        else
          err += 1
          puts "  - ##{recipe.id} ERROR #{res[:message]}"
        end
      end
    end

    puts "[recipes:cache_images] Done total=#{total} ok=#{ok} skipped=#{skip} errors=#{err}"
    exit(1) if err.positive? && !dry_run
  end
end
