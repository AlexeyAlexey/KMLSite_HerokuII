require 'rubygems'
require "sinatra"
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
 
 countR = GpsDate.count
 
 if countR > 100
   then GpsDate.find(:all,:limit => (countR-2)).each{|r| r.delete}
 end
#Client.where(:first_name => 'Andy').first_or_create(:locked => false)
#Client.where("created_at >= :start_date AND created_at <= :end_date",
#  {:start_date => params[:start_date], :end_date => params[:end_date]})

 dataFix = Time.now.to_i
begin
  GpsDate.where("t = :t AND l_x = :l_x AND l_y = :l_y", {:t   => jsonDate["t"].to_i,
                                                         :l_x => jsonDate["ll"][1].to_f,
                                                         :l_y => jsonDate["ll"][0].to_f
                                                        }
             ).first_or_create(:al_z     = jsonDate["al"].to_f,
                               :t_i      = dataFix,
                               :al       = jsonDate["al"].to_f,
                               :vv_0     = jsonDate["vv"][0].to_f,
                               :vv_1     = jsonDate["vv"][1].to_f,
                               :ha       = jsonDate["ha"].to_f,
                               :va       = jsonDate["va"].to_f 
                              )
 rescue => ex # ссылается на обрабатываемый объект Exception
   return "#{ex.class}: #{ex.message}"
 end


return body = message.call(jsonDate["t"], view_url, nil)
#Get json with coordinate
#This input method takes JSON data directly in a param named fixes
#get http://mine-track.appspot.com/get/kml

end

