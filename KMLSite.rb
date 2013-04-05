require "sinatra"
require 'json'
require 'erb'
require 'active_record'
require 'yaml'
require 'fileutils'
path = File.dirname File.expand_path('../KMLSite.rb', __FILE__)
Dir.chdir(File.dirname File.expand_path('../KMLSite.rb', __FILE__))

set :app_file, __FILE__

configure do
      enable :logging, :sessions

      #file = File.new(path + "/log/sinatra.log", 'a+')
      #file.sync = true
      #use Rack::CommonLogger, file

end



error do
  'Sorry there was a nasty error - ' + env['sinatra.error'].name
end

not_found do
  'This is nowhere to be found.'
end

ActiveRecord::Base.establish_connection YAML.load_file(path + "/config/database.yml")
  
  
class GpsDate < ActiveRecord::Base
end

get '/' do

   if !(params[:calendar] =~ /\d{4}-\d{2}-\d{2}/)
     then return erb :index, :layout => true, :locals => {:message => "Enter data"} 
   end 
   #convert time in unix without time 
   setTime = params[:calendar]
  
   begin
      setTime_Date = Time.parse setTime #Years Month Day
      setTime_DateUnix = setTime_Date.to_i #date in Unix format
   rescue => ex # ссылается на обрабатываемый объект Exception
      return erb :index, :layout => true, :locals => {:message => "#{ex.class}: #{ex.message}"}
   end 

   #check out record db
   if !GpsDate.where(:date_fix => setTime_DateUnix).exists? 
     then return erb :index, :layout => true, :locals => {:message => ("The date is not exist: " + params[:calendar])}  
   end

   session[:calendar] = setTime_DateUnix
   
   erb :index, :layout => true, :locals => {:message => false}
   
  
end



get '/maps' do
end



get '/views/googlmaps' do

erb :googlmaps, :layout => false

end



get '/kml' do

 
 strBody = ERB.new(File.read 'load/kml.erb')
 
 @gpsData = GpsDate.where(:date_fix => session[:calendar]) #send to kml.kml file (get '/kml')
 @markEndPoint = @gpsData.last #send to kml.kml file (get '/kml')
 #head file
 content_type 'application/vnd.google-earth.km'
 attachment 'kml'

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
#convert time in unix without time 
 t_i = Time.at data["t_i"]
 t_i_Date = Time.parse t_i.strftime("%Y/%m/%d") 
 t_i_DateUnix = t_i_Date.to_i #date in Unix format

 
#convert time in unix without time
#date of fix in db
 date_fix = Time.now 
 date_fix_Date = Time.parse date_fix.strftime("%Y/%m/%d") #Years Month Day
 date_fix_DateUnix = date_fix_Date.to_i #date in Unix format


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
   gps.t_i_date = t_i_DateUnix
   gps.date_fix = date_fix_DateUnix
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





