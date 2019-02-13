module TimeoutableFields
  extend ::ActiveSupport::Concern

  included do
    include Mongoid::Document

    ## Timeoutable
  end

  module ClassMethods

  end

end
