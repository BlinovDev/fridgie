namespace :import do
  desc "Download, extract, and import recipes"
  task recipes: :environment do
    require 'open-uri'
    require 'json'
    require 'zlib'

    url = 'https://pennylane-interviewing-assets-20220328.s3.eu-west-1.amazonaws.com/recipes-en.json.gz'
    tmp_dir = Rails.root.join('tmp')
    gz_path = tmp_dir.join('recipes-en.json.gz')
    json_path = tmp_dir.join('recipes-en.json')

    # 1. Download the archive
    puts "Downloading recipes archive..."
    URI.open(url) do |remote_file|
      File.open(gz_path, 'wb') { |file| file.write(remote_file.read) }
    end
    puts "Archive downloaded: #{gz_path}"

    # 2. Extract the archive
    puts "Extracting the archive..."
    Zlib::GzipReader.open(gz_path) do |gz|
      File.open(json_path, 'w') { |f| f.write(gz.read) }
    end
    puts "File extracted: #{json_path}"

    # 3. Import data into the database
    puts "Importing recipes into the database..."
    data = JSON.parse(File.read(json_path))

    data.each_with_index do |rec, idx|
      recipe = Recipe.find_or_initialize_by(title: rec['title'])
      recipe.assign_attributes(
        cook_time: rec['cook_time'],
        prep_time: rec['prep_time'],
        ratings: rec['ratings'],
        cuisine: rec['cuisine'],
        category: rec['category'],
        author: rec['author'],
        image: rec['image'],
        ingredients_list: rec['ingredients']
      )
      recipe.save!

      puts "Imported: #{idx+1}/#{data.size}" if (idx+1) % 100 == 0
    end

    puts "Import finished! Total: #{data.size} recipes."

    # 4. Remove temporary files
    File.delete(gz_path) if File.exist?(gz_path)
    File.delete(json_path) if File.exist?(json_path)
    puts "Temporary files deleted."
  end
end
