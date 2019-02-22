module ValidatableFields
  extend ::ActiveSupport::Concern

  included do
    include Mongoid::Document
  end
end
