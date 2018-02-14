#The authenticate action will take the JSON parameters for e-mail and password 
#through the params hash and pass them to the AuthenticateUser command. 
#If the command succeeds, it will send the JWT token back to the user.
class AuthenticationController < ApplicationController
    skip_before_action :authenticate_request
   
    def authenticate
      command = AuthenticateUser.call(params[:email], params[:password])
   
      if command.success?
        render json: { auth_token: command.result }
      else
        render json: { error: command.errors }, status: :unauthorized
      end
    end
end