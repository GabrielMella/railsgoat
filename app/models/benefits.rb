# frozen_string_literal: true
require "fileutils"

class Benefits < ApplicationRecord

  def self.save(file, backup = false)
    data_path = Rails.root.join("public", "data")
    safe_filename = File.basename(file.original_filename)
    full_file_name = data_path.join(safe_filename)
    File.open(full_file_name, "wb+") do |f|
      f.write file.read
    end
    make_backup(file, data_path, full_file_name) if backup == "true"
  end

  def self.make_backup(file, data_path, full_file_name)
    if File.exist?(full_file_name)
      safe_filename = File.basename(file.original_filename)
      backup_path = data_path.join("bak#{Time.zone.now.to_i}_#{safe_filename}")
      FileUtils.cp(full_file_name, backup_path)
    end
  end

end
