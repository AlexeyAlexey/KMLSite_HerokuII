require "sinatra"
require 'json'
require 'erb'
require 'active_record'

set :app_file, __FILE__
Dir.chdir(File.dirname File.expand_path('../KMLSite.rb', __FILE__))

ActiveRecord::Base.establish_connection(#YAML.load_file('db.yaml')
                    :adapter  => "mysql2",
                    :encoding => "utf8",
                    :host     => "127.0.0.1",
                    :username => "root",
                    :password => "18281828",
                    :database => "KMLSite"
)
  
  
class GpsDate < ActiveRecord::Base
end

#:app_file - main application file


get '/' do

  erb :index, :layout => true

end

get '/views/googlmaps' do

erb :googlmaps, :layout => false

end

get '/kml' do

 
 strBody = ERB.new(File.read 'load/kml.kml')
 
 @localTime = (Time.now).to_i
  
 content_type 'application/vnd.google-earth.km'
 attachment 'kml'
 body= strBody.result

 
end




post '/input' do

 begin
   jsonDate = JSON.parse params[:fixes]
 rescue => ex # ссылается на обрабатываемый объект Exception
   return "#{ex.class}: #{ex.message}"
 end

#erb :result, :layout => true, :locals => { :fixes => params[:fixes] }
 view_url = 'http://jgps.me/l/tokentokentoken'

 #message = Proc.new do |time, view_url, error| 
  #  [{"fix_tlist" => time}, { "meta" => {"view_url" => view_url}},"error" => nil].to_json
 #end

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


 dateGPS = Gps_Dates.new do |gps|
   gps.al_z = jsonDate["data"]["al"].to_f
   gps.l_x =  jsonDate["data"]["l"][0].to_f
   gps.l_y =  jsonDate["data"]["l"][1].to_f
   gps.t =    jsonDate["data"]["t"].to_i
   gps.t_i =  jsonDate["data"]["t_i"].to_i
   gps.al =   jsonDate["data"]["al"].to_f
   gps.vv_0 = jsonDate["data"]["vv"][0].to_f
   gps.vv_1 = jsonDate["data"]["vv"][1].to_f
   gps.ha =   jsonDate["data"]["ha"]
   gps.va =   jsonDate["data"]["va"]
 end

 dateGPS.save

return body= message.call(jsonDate["data"]["t"], view_url, nil)
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

