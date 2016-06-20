#!/usr/bin/ruby

require 'rubygems'
require 'json'

file_count = 0
%w(AGENTS NOTIFICATIONS WEB PNP_TEMPLATES DOC CHECKS CHECKMAN).each do |file_type|
  file_count += ENV[file_type].split(',').length if ENV[file_type] 
end

data = {
  "version.min_required" => ENV["CMK_MIN_VERSION"],
  "title"                => ENV["TITLE"],
  "version.packaged"     => ENV["CMK_PKG_VERSION"],
  "version"              => ENV["VERSION"],
  "name"                 => ENV["NAME"],
  "files"=> {
    "agents"        => ENV["AGENTS"] ? ENV["AGENTS"].split(',') : [] ,
    "notifications" => ENV["NOTIFICATIONS"] ? ENV["NOTIFICATIONS"].split(',') : [],
    "web"           => ENV["WEB"] ? ENV["WEB"].split(',') : "",
    "pnp-templates" => ENV["PNP_TEMPLATES"] ? ENV["PNP_TEMPLATES"].split(',') : [],
    "doc"           => ENV["DOC"] ? ENV["DOC"].split(',') : [],
    "checks"        => ENV["CHECKS"] ? ENV["CHECKS"].split(',') : [],
    "checkman"      => ENV["CHECKMAN"] ? ENV["CHECKMAN"].split(',') : [],
  },
  "author"               => ENV["AUTHOR"],
  "num_files"            => file_count, 
  "download_url"         => ENV["URL"],
  "description"          => ENV["DESCRIPTION"]
}

puts JSON.pretty_generate(data)

