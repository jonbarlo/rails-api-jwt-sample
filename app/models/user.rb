class User < ApplicationRecord
    has_secure_password
    enum access_level: [:sales, :admin, :operations]
end
