class DefaultController < ApplicationController
    skip_before_action :authenticate_request

    def index
        actual_environment = ENV["RACK_ENV"] 
        @message = "{ \"api\" : { \"message\":\"welcome\",\"environment\":\"#{actual_environment}\",\"status\":\"ok\" } }"
        render :json => @message
    end
    
end
