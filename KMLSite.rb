require "sinatra"
require 'json'


#:app_file - main application file
set :app_file, __FILE__

Dir.chdir(File.dirname File.expand_path('../KMLSite.rb', __FILE__))

get '/' do

  erb :index, :layout => true

end

get '/views/googlmaps' do

erb :googlmaps, :layout => false

end

get '/kml' do

 send_file "load/kml", :filename => "kml", :type => 'application/vnd.google-earth.kml+xml'
 

end




post '/input' do

 begin
   jsonDate = JSON.parse params[:fixes]
 rescue => ex # ссылается на обрабатываемый объект Exception
   return "#{ex.class}: #{ex.message}"
 end

#erb :result, :layout => true, :locals => { :fixes => params[:fixes] }
 view_url = 'http://jgps.me/l/tokentokentoken'

 message = Proc.new do |time, view_url, error| 
      
   JSON.generate [{"fix_tlist" => time}, {"meta" => {"view_url" => view_url}}, error]
 
 end

if jsonDate["error"]
  then return message.call(jsonDate["data"]["t"], view_url, {"error" => jsonDate["error"]})
  else return message.call(jsonDate["data"]["t"], view_url)
end 


#Get json with coordinate

#This input method takes JSON data directly in a param named fixes


#get http://mine-track.appspot.com/get/kml

end

post '/load' do


  #fileDir = File.expand_path('../KMLSite.rb', __FILE__)
  #fileDir = File.dirname(fileDir) + "/load/"

  #File.open(fileDir + params['loadfile'][:filename], "w") do |f|
    #f.write(params['loadfile'][:tempfile].read)
  #end
 
#erb :kml, :layout => true, :locals => { :loadfile => params['fixes'][:tempfile] } 
 return "The file was successfully uploaded! #{params[:fixes]}"
 

end

get '/result' do




end

