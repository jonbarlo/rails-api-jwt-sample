class ProductController < ApplicationController
    before_action :authenticate_request
    def index
        @products = Product.all
        render json: @products
    end
end
