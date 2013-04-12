require 'rubygems'
require "sinatra"
#require 'sinatra/base'
#require 'sinatra/contrib/all'
require 'json'
require 'erb'
require 'active_record'
require 'yaml'
require 'fileutils'




disable :protection
set :root, './'
set :app_file, __FILE__


error do
  'Sorry there was a nasty error - ' #+ env['sinatra.error'].name
end

not_found do
  'This is nowhere to be found.'
end

ActiveRecord::Base.establish_connection "mysql2://b2de1d2c131a92:ed316f52@us-cdbr-east-03.cleardb.com/heroku_bd8015972428027" #YAML.load_file(path + "/config/database.yml")
  
  
class GpsDate < ActiveRecord::Base
end

get '/' do
  
   erb :googleMaps#:index, :layout => true
   
  
end


get '/kml2' do

   constCountR = 10
   countR = GpsDate.count  
   
   if  countR < constCountR
     then constCountR = countR
   end    
            
   @gpsData = GpsDate.last(constCountR) 
   @markEndPoint = GpsDate.last

   content_type 'application/vnd.google-earth.kml+xml', :charset => 'utf-8'
   headers 'Content-Type' => "application/vnd.google-earth.kml+xml;charset=utf-8" 
                
   cache_control :public, :must_revalidate, :max_age => 60
   erb :kml_kml, :layout => false, :locals => {:gpsData => @gpsData, :markEndPoint => @markEndPoint}
    
end

get '/addCord' do

erb :index, :layout => true

end

post '/input' do

 begin
   #[{"t"=>1365795461000, "ll"=>[48.563484, 39.31413], "ha"=>22, "va"=>0, "al"=>0, "vv"=>[0, 0]}]
   jsonDate = JSON.parse params[:fixes]
   #{"t"=>1365795806000, "ll"=>[48.563452, 39.314097], "ha"=>24, "va"=>0, "al"=>0, "vv"=>[0, 0]}
   jsonDate = jsonDate[0]
 rescue => ex # ссылается на обрабатываемый объект Exception
   return "#{ex.class}: #{ex.message}"
 end

 if jsonDate["t"].is_a? Array
   then jsonDate["t"] = jsonDate["t"][0]
 end
<<-EOF
require 'pony'
    Pony.mail(
      :from => 'ialexey.kondratenko@gmail.com',
      :to => 'alexey.kondratenko@mail.ru',
      :subject => 'heroku',
      :body => jsonDate,
      :port => '587',
      :via => :smtp,
      :via_options => { 
        :address              => 'smtp.gmail.com', 
        :port                 => '587', 
        :enable_starttls_auto => true, 
        :user_name            => 'ialexey.kondratenko', 
        :password             => '1828alexey', 
        :authentication       => :plain, 
        :domain               => 'gmail.com'
      })
EOF   


 

 view_url = nil#'http://jgps.me/l/tokentokentoken'


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

 if jsonDate.has_key? "error"
   then return body= message.call(jsonDate["t"], view_url, jsonDate["error"])
 end 


 if jsonDate.has_key?("found") 
   then return body= message.call(jsonDate["t"], view_url, "sometimes false, then no data")
 end 

 dataFix = Time.now.to_i
 dateGPS = GpsDate.new do |gps|
   gps.al_z     = jsonDate["al"].to_f
   gps.l_x      = jsonDate["ll"][0].to_f
   gps.l_y      = jsonDate["ll"][1].to_f
   gps.t        = jsonDate["t"].to_i
   gps.t_i      = dataFix
   gps.al       = jsonDate["al"].to_f
   gps.vv_0     = jsonDate["vv"][0].to_f
   gps.vv_1     = jsonDate["vv"][1].to_f
   gps.ha       = jsonDate["ha"].to_f
   gps.va       = jsonDate["va"].to_f   
 end

begin
   dateGPS.save
 rescue => ex # ссылается на обрабатываемый объект Exception
   return "#{ex.class}: #{ex.message}"
 end


return body = message.call(jsonDate["t"], view_url, nil)
#Get json with coordinate
#This input method takes JSON data directly in a param named fixes
#get http://mine-track.appspot.com/get/kml

end

