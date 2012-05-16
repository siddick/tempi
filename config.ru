require 'sinatra'

TFiles = Hash[Dir["templates/*"].map{|f| [ f, File.read(f) ]}]

get '/templates' do
  match_files = (params["t"] || "default").split(",").uniq.join("|")
  files = TFiles.keys.grep(/\/(#{match_files})\.rb$/)
  content_type :text
  files.map{|f| TFiles[f] }.join("\n")
end

run Sinatra::Application
