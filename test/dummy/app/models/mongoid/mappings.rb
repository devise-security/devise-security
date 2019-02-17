Dir.glob(File.expand_path('./../*.rb',__FILE__)).each { |r| require r }
module Mongoid
  module Mappings
    extend ::ActiveSupport::Concern

    included do
      self.devise_modules.each do |devise_module_name|
        begin
          module_name = "#{devise_module_name.to_s.classify}Fields".constantize
          include module_name
        rescue => e
          puts "#{module_name} #{devise_module_name} not found"
          raise e
        end
      end
    end
  end
end
