require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe CarQuery do
  use_vcr_cassette :record => :new_episodes 
  context "Base" do
    it "returns an Addressable::URI Object with the base url" do
      CarQuery.url.to_s.should == "http://www.carqueryapi.com/api/0.3/"
      CarQuery.url.class.should == Addressable::URI
    end

    it "raises an error if api returns error" do
      lambda{CarQuery.query}.should raise_error(CarQuery::APIError)
    end

    it "returns parsed_response if the query its good" do
      request = CarQuery.url
      request.query_values = {:cmd => "getYears"}
      lambda{CarQuery.query(request.to_s)}.should_not raise_error(CarQuery::APIError)
    end

    it "returns a non_scoped parsed_response if key is passed as a param" do
      request = CarQuery.url
      request.query_values = {:cmd => "getYears"}
      CarQuery.query(request.to_s).should == {"Years"=>{"min_year"=>"1940", "max_year"=>"2012"}}
      CarQuery.query(request.to_s,"Years").should == {"min_year"=>"1940", "max_year"=>"2012"}
    end
  end
end

describe CarQuery::Years do
  use_vcr_cassette :record => :new_episodes 
  it "returns range of years of models avaible in the db" do
    CarQuery::Years.get.should == {"min_year"=>"1940", "max_year"=>"2012"}
  end
end

describe CarQuery::Makes do
  use_vcr_cassette :record => :new_episodes

  it "returns all makers" do
    CarQuery::Makes.get.should_not be_empty
  end

  it "accepts params as a hash" do
    lambda{CarQuery::Makes.get({:year => 2000})}.should_not raise_error
  end

  it "returns all makers that has models in a certain year" do
    CarQuery::Makes.get({:year => 2012}).should_not be_empty
  end

  it "returns all makers that sold cars in USA" do
    CarQuery::Makes.get({:sold_in_us => 1}).should_not be_empty
  end
end

describe CarQuery::Models do
  use_vcr_cassette :record => :new_episodes

  it "should raise error if no maker is passed" do
    lambda{CarQuery::Models.get}.should raise_error(CarQuery::APIError)
  end

  it "should not raise error if a maker is passed" do
    lambda{CarQuery::Models.get({:make => "ford"})}.should_not raise_error(CarQuery::APIError)
  end

  it "returns all models for a certain maker" do
    response = CarQuery::Models.get({:make => "ford"})
    response.should_not be_empty
    response.first.should == {"model_name"=>"021 C", "model_make_id"=>"ford"}
  end

  it "returns all models from a maker by year" do
    response = CarQuery::Models.get({:make => "ford", :year => "2012"})
    response.should_not be_empty
    response.first.should == {"model_name"=>"Bantam","model_make_id"=>"ford"}
  end
end

describe CarQuery::Trims do
  use_vcr_cassette :record => :new_episodes

  it "should return 500 first trims" do
    response = CarQuery::Trims.get
    response.should_not be_empty
    response.size.should == 500
  end

  it "accepts variables like year,model,make etc." do
    response = CarQuery::Trims.get({:year => 2012, :make => "ford", :model => "f-350"})
    response.should_not be_empty
    response.first.should == {"model_id"=>"48922", "model_make_id"=>"ford", "model_name"=>"F-350", "model_trim"=>"Super Duty King Ranch", "model_year"=>"2012", "model_body"=>"Pickup", "model_engine_position"=>"Front", "model_engine_cc"=>"6200", "model_engine_cyl"=>"8", "model_engine_type"=>"V", "model_engine_valves_per_cyl"=>"2", "model_engine_power_ps"=>"390", "model_engine_power_rpm"=>"5500", "model_engine_torque_nm"=>"548", "model_engine_torque_rpm"=>"4500", "model_engine_bore_mm"=>nil, "model_engine_stroke_mm"=>nil, "model_engine_compression"=>nil, "model_engine_fuel"=>"Flex Fuel", "model_top_speed_kph"=>nil, "model_0_to_100_kph"=>nil, "model_drive"=>"Rear", "model_transmission_type"=>"6-speed shiftable automatic", "model_seats"=>nil, "model_doors"=>nil, "model_weight_kg"=>nil, "model_length_mm"=>"6269", "model_width_mm"=>"2029", "model_height_mm"=>"1961", "model_wheelbase_mm"=>"3967", "model_lkm_hwy"=>nil, "model_lkm_mixed"=>nil, "model_lkm_city"=>nil, "model_fuel_cap_l"=>"132", "model_sold_in_us"=>"1", "make_display"=>"Ford", "make_country"=>"USA"}
  end

  it "accepts a full_results param that give us only model,year and make instead of all data of a trim" do
    response = CarQuery::Trims.get({:year => 2012, :make => "ford", :model => "f-350", :full_results => 0})
    response.should_not be_empty
    response.first.should == {"model_id"=>"48922", "model_year"=>"2012", "model_make_id"=>"ford", "model_name"=>"F-350", "model_trim"=>"Super Duty King Ranch", "make_display"=>"Ford", "make_country"=>"USA"}
  end

  it "accepts a keyword param that tries to find a trim by keywords" do
    response = CarQuery::Trims.get({:keyword => "ford f-350", :full_results => 0})
    response.should_not be_empty
    response.first.should == {"model_id"=>"48922", "model_year"=>"2012", "model_make_id"=>"ford", "model_name"=>"F-350", "model_trim"=>"Super Duty King Ranch", "make_display"=>"Ford", "make_country"=>"USA"}
  end
  
  it "accepts a keyword param that tries to find a trim by keywords and could return empty if theres no match" do
    response = CarQuery::Trims.get({:keyword => "no matching keyword here!", :full_results => 0})
    response.should be_empty
  end
 
  it "returns an empty hash if theres no match" do
    response = CarQuery::Trims.get({:year => 2015, :make => "ford", :model => "f-350"})
    response.should be_empty
  end
end

describe CarQuery::Trims do
  use_vcr_cassette :record => :new_episodes

  it "raises an error if no model param is passed" do
    lambda{CarQuery::Model.get}.should raise_error(CarQuery::APIError)
  end

  it "dont raises an error if model param is passed" do
    lambda{CarQuery::Model.get({:model =>"48922"})}.should_not raise_error(CarQuery::APIError)
  end

  it "returns all data of a certain model" do
    response = CarQuery::Model.get({:model =>'48922'})
  end
end
