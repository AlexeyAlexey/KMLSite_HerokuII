class CreateGpsDates < ActiveRecord::Migration

def up
   create_table :gps_dates do |t|
       t.float   :al_z,     :default => 0,  :null => false
       t.float   :l_x,                      :null => false
       t.float   :l_y,      :default => 0,  :null => false
       t.integer :t,        :limit => 11,   :null => false
       t.integer :t_i,      :limit => 11,   :null => false
       t.float   :al,       :default => 0,  :null => false
       t.float   :vv_0,     :default => 0,  :null => false
       t.float   :vv_1,     :default => 0,  :null => false
       t.string  :ha
       t.string  :va
       
   end
end


def down
   drop_table :gps_dates
end

end
