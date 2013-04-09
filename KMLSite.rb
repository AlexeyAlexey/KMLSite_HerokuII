
require "sinatra"
require 'json'
require 'erb'
require 'active_record'
require 'yaml'
require 'fileutils'

#Dir.chdir(File.dirname File.expand_path('../KMLSite.rb', __FILE__))
set :root, './'
set :app_file, __FILE__

configure do
      enable :logging, :sessions

      #file = File.new(path + "/log/sinatra.log", 'a+')
      #file.sync = true
      #use Rack::CommonLogger, file

end



error do
  #'Sorry there was a nasty error - ' + env['sinatra.error'].name
end

not_found do
  'This is nowhere to be found.'
end

ActiveRecord::Base.establish_connection "mysql2://b2de1d2c131a92:ed316f52@us-cdbr-east-03.cleardb.com/heroku_bd8015972428027" #YAML.load_file(path + "/config/database.yml")
  
  
class GpsDate < ActiveRecord::Base
end

get '/' do
  
   erb :index, :layout => true
   
  
end


get '/get/cord.kml' do

   constCountR = 10
   countR = GpsDate.count  
   

        if  countR < constCountR
          then constCountR = countR
        end    
            
        @gpsData = GpsDate.last(constCountR) 
        @markEndPoint = GpsDate.last
        
 
        strERB = File.open('./load/kml.erb', File::RDONLY).read
        strBody = ERB.new strERB 

        content_type 'application/vnd.google-earth.kml+xml'
        attachment 'cord.kml'

        body = strBody.result(binding)
 
 
end


get '/favicon.ico'   do

constCountR = 10
   countR = GpsDate.count  
   

        if  countR < constCountR
          then constCountR = countR
        end    
            
        @gpsData = GpsDate.last(constCountR) 
        @markEndPoint = GpsDate.last
        
 
        strERB = File.open('./load/kml.erb', File::RDONLY).read
        strBody = ERB.new strERB 

        content_type 'application/vnd.google-earth.kml+xml'
        attachment 'cord.kml'

        body = strBody.result(binding)




end



post '/input' do

 begin
   jsonDate = JSON.parse params[:fixes]
 rescue => ex # ссылается на обрабатываемый объект Exception
   return "#{ex.class}: #{ex.message}"
 end


 view_url = 'http://jgps.me/l/tokentokentoken'


 message = lambda do |time, view_url, error|              
              
              h = {"fix_tlist" => time}

              if view_url
                then h["meta"] = {"view_url" => view_url}
              end

              if  error
                 then h["error"] = error
              end

              h.to_json         
  
           end

 content_type 'application/JSON'
 attachment 'JSON'
 
 

 if jsonDate["error"]
   then return body= message.call(jsonDate["data"]["t"], view_url, jsonDate["error"])
         
 end 

 if !jsonDate["found"] 
   then return body= message.call(jsonDate["data"]["t"], view_url, "sometimes false, then no data")
 end 

 data = jsonDate["data"]
 dateGPS = GpsDate.new do |gps|
   gps.al_z     = data["al"].to_f
   gps.l_x      = data["l"][0].to_f
   gps.l_y      = data["l"][1].to_f
   gps.t        = data["t"].to_i
   gps.t_i      = data["t_i"].to_i
   gps.al       = data["al"].to_f
   gps.vv_0     = data["vv"][0].to_f
   gps.vv_1     = data["vv"][1].to_f
   gps.ha       = data["ha"]
   gps.va       = data["va"]   
 end

begin
   dateGPS.save
 rescue => ex # ссылается на обрабатываемый объект Exception
   return "#{ex.class}: #{ex.message}"
 end

 

return body = message.call(jsonDate["data"]["t"], view_url, nil)
#Get json with coordinate
#This input method takes JSON data directly in a param named fixes
#get http://mine-track.appspot.com/get/kml

end

get '/sinatralog' do

 return File.open('./log/sinatra.log').read

end





