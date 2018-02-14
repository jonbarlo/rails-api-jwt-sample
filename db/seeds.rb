# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

#create default admin user
p "Creating default database users..."
admin = User.create!(email: "admin@mail.com" , password: "123456" , password_confirmation: "123456", access_level: :admin, first_name: "John", middle_name: "Daniel", last_name: "Doe")
p "-> created admin@mail.com!"
sales = User.create!(email: "sales@mail.com" , password: "123456" , password_confirmation: "123456", access_level: :sales, first_name: "Bob", middle_name: "Richard", last_name: "Foo")
p "-> created sales@mail.com!"
operations = User.create!(email: "operations@mail.com" , password: "123456" , password_confirmation: "123456", access_level: :operations, first_name: "Jim", middle_name: "Ethan", last_name: "Smith")
p "-> created operations@mail.com!"

Product.create!(name:"Asimo", description:"Honda's first robot")
Product.create!(name:"Mind Storm", description:"Llego's IoT for kids")
Product.create!(name:"Raspberry Pi", description:"Micro controller")
p "-> created products!"