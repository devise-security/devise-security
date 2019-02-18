module PasswordArchivableFields
  extend ::ActiveSupport::Concern

  included do
    include Mongoid::Document

    ## PasswordArchivableFields
  end
end
