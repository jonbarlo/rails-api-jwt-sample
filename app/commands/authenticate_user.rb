class AuthenticateUser
    prepend SimpleCommand
  
    def initialize(email, password)
      @email = email
      @password = password
    end
  
    def call
      JsonWebToken.encode(user_id: user.id, user_email: user.email, user_access_level: user.access_level) if user
    end
  
    private
  
    attr_accessor :email, :password
  
    def user
      user = User.find_by_email(email)
      #puts "user authenticated is : #{user.inspect}"
      #puts "password to authenticate is : #{password}"
      #puts "user.authenticate(password) is : #{user.authenticate(password)}"
      return user if user && user.authenticate(password)
  
      errors.add :user_authentication, 'invalid credentials'
      nil
    end
  end