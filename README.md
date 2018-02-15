# README

Rails API using JWT as auth framework this will have user with roles

Things we will cover:

* Project generation
    
    ### create a new Rails API-only application
    `rails new rails-jwt-api-sample --api`
    ### create the user model
    `rails g model User first_name middle_name last_name token email password_digest`
    ### run the migrations
    `rails db:migrate`
    ### update Gemfile to include bcrypt
    `gem 'bcrypt'`
    ### and install it
    `bundle install`
    ### lets include and use bycrypt on our model
    ### app/models/user.rb
    ```
    class User < ApplicationRecord
        has_secure_password
    end
    ```
    ### update Gemfile to include JWT
    `gem 'jwt'`
    ### and install it
    `bundle install`
    ### write a singleton class for wrapping the JWT logic through its global variable
    ### lib/json_web_token.rb
    ```
    class JsonWebToken
        class << self
            def encode(payload, exp = 24.hours.from_now)
            payload[:exp] = exp.to_i
            JWT.encode(payload, Rails.application.secrets.secret_key_base)
            end

            def decode(token)
            body = JWT.decode(token, Rails.application.secrets.secret_key_base)[0]
            HashWithIndifferentAccess.new body
            rescue
            nil
            end
        end
    end
    ```
    ### include the lib directory when the Rails application loads
    ### that way we will force the use of our new singleton class
    ### config/application.rb
    ### add this line
    `config.autoload_paths << Rails.root.join('lib')`
    ### update Gemfile to include simple command is similar to the role of a helper, but instead of facilitating the connection between the controller and the view, it does the same for the controller and the model
    `gem 'simple_command'`
    ### and install it
    `bundle install`

    ### create new folder commands under app main directory

    ### create new command has to take the user's e-mail and password and return the user if the credentials match
    
    ### app/commands/authenticate_user.rb
    ```
    class AuthenticateUser
    prepend SimpleCommand

    def initialize(email, password)
        @email = email
        @password = password
    end

    def call
        JsonWebToken.encode(user_id: user.id) if user
    end

    private

    attr_accessor :email, :password

    def user
        user = User.find_by_email(email)
        return user if user && user.authenticate(password)

        errors.add :user_authentication, 'invalid credentials'
        nil
    end
    end
    ```
    ### create new command to check if a token that's been appended to a request is valid

    ### app/commands/authorize_api_request.rb
    ```
    class AuthorizeApiRequest
    prepend SimpleCommand

    def initialize(headers = {})
        @headers = headers
    end

    def call
        user
    end

    private

    attr_reader :headers

    def user
        @user ||= User.find(decoded_auth_token[:user_id]) if decoded_auth_token
        @user || errors.add(:token, 'Invalid token') && nil
    end

    def decoded_auth_token
        @decoded_auth_token ||= JsonWebToken.decode(http_auth_header)
    end

    def http_auth_header
        if headers['Authorization'].present?
        return headers['Authorization'].split(' ').last
        else
        errors.add(:token, 'Missing token')
        end
        nil
    end
    end
    ```

### Implementing helper methods into the controllers
### Create new controller for logging in users
### app/controllers/authentication_controller.rb
```
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
```

### create a new endpoint for this action/controller

### config/routes.rb
`post 'authenticate', to: 'authentication###authenticate'`

### we need to expose the current_user to 'persist' in order to have current_user available to all controllers, it has to be declared in the ApplicationController

### app/controllers/application_controller.rb
```
class ApplicationController < ActionController::API
 before_action :authenticate_request
  attr_reader :current_user

  private

  def authenticate_request
    @current_user = AuthorizeApiRequest.call(request.headers).result
    render json: { error: 'Not Authorized' }, status: 401 unless @current_user
  end
end
```

### create user roles

### update the user model to have enum with roles
### app/models/user.rb
`enum access_level: [:sales, :admin, :operations]`

### update active record migration
### add this right below password_digest
`t.integer :access_level`

### update authenticate user command to encode and response back the logged user's role
### app/commands/authenticate_user.rb
### update call method to send email and user_access_level or role
`JsonWebToken.encode(user_id: user.id, user_email: user.email, user_access_level: user.access_level) if user`

### update database seed file to add users for testing
### db/seeds.rb
`admin = User.create!(email: "admin@mail.com" , password: "123456" , password_confirmation: "123456", access_level: :admin, first_name: "John", middle_name: "Daniel", last_name: "Doe")`

### let's (not...lol, as you will see we will perform each task separately) scaffold a resource so see how authorizarion works
### create the model
`rails g model Product name:string description:text`
### create controller
`rails g controller Product`
### modify controller to display all products only after authentication
```
before_action :authenticate_request
def index
    @products = Product.all
    render json: @products
end
```
### add new route
`get 'produtcs', to: 'produtc#index'`

### update database seed file to add products for testing
### db/seeds.rb
`Product.create!(name:"Asimo", description:"Honda's first robot")`

### reload updated migration for user
```
    rails db:drop
    rails db:create
    rails db:migrate
    rails db:seed
```

### migrate dbms engine from sqllite to postgres (optional but required in case of uploading this project to a cloud like Heroku)

### add entry to Gemfile
gem 'pg'

### update confg/database.yml with your local user data
### in case of uploading this in heroku it will be auto-generated
development:
  adapter: postgresql
  host: localhost
  username: user
  database: app-dev
### now run the server and have fun!

* Ruby version

* System dependencies
[JWT](https://jwt.io/) - JWT official website

* Configuration

* Database creation
```
    rails db:drop
    rails db:create
```
* Database initialization
```
    rails db:migrate
    rails db:seed
```
* How to run the web api
    rails server -p 3110

* How to test the web api
### api call using curl
```
    curl -H "Content-Type: application/json" -X POST -d '{"email":"admin@mail.com","password":"123456"}' http://localhost:3110/authenticate
```
### take note of the JSON response
{"auth_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJ1c2VyX2VtYWlsIjoiYWRtaW5AbWFpbC5jb20iLCJ1c2VyX2FjY2Vzc19sZXZlbCI6ImFkbWluIiwiZXhwIjoxNTE4NzM1ODYyfQ.HowwXLphSllo6hDK_t6hW4rq3hadSmxIFJA2D15KYCg"}

### lets test our endpoint is not accessible without an auth token
```
curl http://localhost:3110/products
{"error":"Not Authorized"}
```

### now lets give a try with the recently generated token
`curl -H "Authorization: TOKEN_HERE " http://localhost:3000/products`

### now use the token
```
curl -H "Authorization: eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJ1c2VyX2VtYWlsIjoiYWRtaW5AbWFpbC5jb20iLCJ1c2VyX2FjY2Vzc19sZXZlbCI6ImFkbWluIiwiZXhwIjoxNTE4NzM1ODYyfQ.HowwXLphSllo6hDK_t6hW4rq3hadSmxIFJA2D15KYCg" http://localhost:3110/products
```

### response will show all products
```
[{"id":1,"name":"Asimo","description":"Honda's first robot","created_at":"2018-02-14T22:44:24.204Z","updated_at":"2018-02-14T22:44:24.204Z"},{"id":2,"name":"Mind Storm","description":"Llego's IoT for kids","created_at":"2018-02-14T22:44:24.207Z","updated_at":"2018-02-14T22:44:24.207Z"},{"id":3,"name":"Raspberry Pi","description":"Micro controller","created_at":"2018-02-14T22:44:24.209Z","updated_at":"2018-02-14T22:44:24.209Z"}]
```
* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

Just clone the repo and push to master ;) its 100% open source feel free to play around.

I have choosed to deploy this sample to Heroku
After setting up project on heroku you just have to execute the following commands for deploying the app
```
heroku create
git push heroku master
```
# Thanks to SoftonITG for the opportiny given on writting down a tech article that could be helpful for someone and/or catch the eye of IT tech people
If you missed something, the project has been uploaded on GitHub. If you have any questions, do not hesitate to ask in the comments or feel free to message me on Github.