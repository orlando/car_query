# encoding: utf-8
require 'httparty'
require 'addressable/uri'

# @author Orlando Del Aguila
# Holds all CarQuery methods
module CarQuery
  # @author Orlando Del Aguila
  # raised when the api returns error.
  class APIError < StandardError;end

  class << self; attr_reader :url; end
  @url = Addressable::URI.parse("http://www.carqueryapi.com/api/0.3/")

  # @author Orlando Del Aguila
  # Contains query method for years
  module Years
  # @author Orlando Del Aguila
  # Returns max and min years of models. 
  # @return [Hash] A hash min_year and max_year
  # @example Returns years
  #   CarQuery::Years.get #=> {"min_year"=>"1940", "max_year"=>"2012"}
    def self.get
      request = CarQuery.url; request.query_values = {:cmd => "getYears"}
      CarQuery.query(request,"Years")
    end
  end

  # @author Orlando Del Aguila
  # Contains query method for makes
  module Makes
    # @author Orlando Del Aguila
    # Returns Makes.
    # @param [Hash] params the options to return makes.
    # @option params [String] :year ('') returns makes that have model of this year
    # @option params [String] :sold_in_us ('') 1(sold in US), 0(not sold in US)
    # @return [Hash] with makes
    # @example Returns makes list that has models from 2012
    #   CarQuery::Makes.get({:year => 2012}) #=> [{"make_id"=>"acura", "make_display"=>"Acura"...}]
    def self.get(params={})
      params.delete(:cmd)
      request = CarQuery.url
      request.query_values = {:cmd => "getMakes"}.merge(params)
      CarQuery.query(request,"Makes")
    end
  end

  # @author Orlando Del Aguila
  # Contains query method for models
  module Models
    # @author Orlando Del Aguila
    # Returns Models
    # @param [Hash] params the options to return models.
    # @option params [String] :make The make of the models (required)
    # @option params [String] :year ('') Model year
    # @option params [String] :sold_in_us ('') 1(sold in US), 0(not sold in US)
    # @option params [String] :body ('') the body type. ex Coupe, Sedan, SUV, Pickup, Crossover, Minivan, etc.
    # @return [Hash] with models
    # @example Returns makes list that has models from 2012
    #   CarQuery::Models.get({:make => "ford", :year => "2012"}) #=> [{"model_name"=>"Bantam", "model_make_id"=>"ford"}...]
    # @raise [APIError] if :make param is missing
    def self.get(params={})
      params.delete(:cmd)
      request = CarQuery.url
      request.query_values = {:cmd => "getModels"}.merge(params)
      CarQuery.query(request,"Models")
    end
  end

  # @author Orlando Del Aguila
  # Contains query method for trims
  module Trims
    # @author Orlando Del Aguila
    # Returns Model Trims, all params are optional, if no param is passed then returns full results for all trims from all models (results are limited to 500).
    # @param [Hash] params the options to return a trim.
    # @option params [String] :body ('') the body type. ex Coupe, Sedan, SUV, Pickup, Crossover, Minivan, etc. 
    # @option params [String] :doors ('') number of doors
    # @option params [String] :drive ('') ex Front, Rear, AWD, 4WD, etc
    # @option params [String] :engine_position ('') ex Front, Middle, Rear
    # @option params [String] :engine_type ('') ex V, in-line, etc
    # @option params [String] :fuel_type ('') ex Gasoline, Diesel, etc
    # @option params [String] :full_results ('') 1 by default. Set to 0 to include only basic year / make /model / trim data (improves load times)
    # @option params [String] :keyword ('') Keyword search. Searches year, make, model, and trim values
    # @option params [String] :make ('') Make ID
    # @option params [String] :min_cylinders ('') Minimum Number of cylinders
    # @option params [String] :min_lkm_hwy ('') Maximum fuel efficiency (highway, l/100km)
    # @option params [String] :min_power ('') Minimum engine power (PS)
    # @option params [String] :min_top_speed ('') Minimum Top Speed (km/h)
    # @option params [String] :min_torque ('') Minimum Torque (nm)
    # @option params [String] :min_weight ('') Minimum Weight (kg)
    # @option params [String] :min_year ('') Earliest Model Year
    # @option params [String] :max_cylinders ('') Maximum Number of cylinders
    # @option params [String] :max_lkm_hwy ('') Minimum fuel efficiency (highway, l/100km)
    # @option params [String] :max_power ('') Minimum engine power (HP)
    # @option params [String] :max_top_speed ('') Maximum Top Speed (km/h)
    # @option params [String] :max_torque ('') Maximum Torque (nm)
    # @option params [String] :max_weight ('') Maximum Weight (kg)
    # @option params [String] :max_year ('') Latest Model Year
    # @option params [String] :model ('') Model Name
    # @option params [String] :seats ('') Number of Seats
    # @option params [String] :sold_in_us ('') 1(sold in US), 0(not sold in US)
    # @option params [String] :year ('') Model Year
    # @raise [APIError] if :model param is missing.
    # @return [Hash] Results are sorted by year, make, model, and trim. Results are limited to 500 records
    # @example Returns trims by keyword and only basic results
    #   CarQuery::Trims.get({:keyword => "ford f-350", :full_results => 0}) #=> [{"model_id":"48922","model_year":"2012"...}]
    def self.get(params={})
      params.delete(:cmd)
      request = CarQuery.url
      request.query_values = {:cmd => "getTrims"}.merge(params)
      CarQuery.query(request,"Trims")
    end
  end

  # @author Orlando Del Aguila
  # Contains query method for model
  module Model
    # @author Orlando Del Aguila
    # Returns Model Trims, all params all optional, if no param is passed then returns full results for all trims from all models.
    # @param [Hash] params the options to return a model.
    # @option params [Integer] :model The model_id (required)
    # @return [Hash] with all model data or empty
    # @example Returns all data of the Ford F-350 2012
    #   CarQuery::Model.get({:model =>"48922"}) #=> {"model_id":"48922","model_make_id":"ford"...}
    def self.get(params={})
      params.delete(:cmd)
      request = CarQuery.url
      request.query_values = {:cmd => "getModel"}.merge(params)
      CarQuery.query(request,"Model")
    end

  end
  
  protected
  # @author Orlando Del Aguila
  # Contains base query method 
  def self.query(url=self.url,key="")
    if key == "Model"
      response = HTTParty.get(url).first
      raise APIError,response.last if response.first == "error"
      return response
    end
    response = HTTParty.get(url)
    raise APIError,response["error"] if response.has_key?("error")
    return response.parsed_response[key] unless key.empty?
    response.parsed_response
  end
  
end
