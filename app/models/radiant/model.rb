require 'annotatable'

class Radiant::Model < ActiveRecord::Base

  # This is an abstract class
  self.abstract_class = true

  # Make it easy for models to declare class-level annotations
  include Annotatable

end
