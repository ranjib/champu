require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_group 'champu' , 'lib/'
end
$:.push File.join(File.dirname(__FILE__), '..', 'lib')

require 'champu'
