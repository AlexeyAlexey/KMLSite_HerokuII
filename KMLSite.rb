require "sinatra"

#:app_file - main application file
set :app_file, __FILE__


get '/' do

  erb :index, :layout => true

end

post '/input' do


erb :result, :layout => true, :locals => { :fixes => params[:fixes] }


#Get json with coordinate

#This input method takes JSON data directly in a param named fixes


#get http://mine-track.appspot.com/get/kml

end

post '/load' do


fileDir = File.expand_path('../KMLSite.rb', __FILE__)
fileDir = File.dirname(fileDir) + "/load"

string_io = request.body # will return a StringIO
      
data_bytes = string_io.read # read the stream as bytes
      
# create the file path
path = File.join(fileDir, params[:loadfile])
# Write it to disk...
File.open(path, 'w') {|f| f.write(string_io.read) }
 

end

get '/result' do




end

