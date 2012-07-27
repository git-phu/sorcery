module Sorcery
  module Model
    module Submodules
      # This submodule helps you login users from external providers such as Twitter.
      # This is the model part which handles finding the user using access tokens.
      # For the controller options see Sorcery::Controller::External.
      #
      # Socery assumes (read: requires) you will create external users in the same table where
      # you keep your regular users,
      # but that you will have a separate table for keeping their external authentication data,
      # and that that separate table has a few rows for each user, facebook and twitter 
      # for example (a one-to-many relationship).
      #
      # kevinsf90 (7/26/2012): Adding ability to have an additional table to keep track of auth providers
      # and sorcery's default table will reference records from this table
      #
      # External users will have a null crypted_password field, since we do not hold their password.
      # They will not be sent activation emails on creation.
      module External
        def self.included(base)
          base.sorcery_config.class_eval do
            attr_accessor :authentications_class,
                          :authentications_user_id_attribute_name,
                          :provider_attribute_name,
                          :provider_attribute_is_key,
                          :providers_class,
                          :providers_class_attribute_name,
                          :provider_uid_attribute_name,
                          :providers_class_require_email_on_save,
                          :providers_class_email_attribute_name 

          end
          
          base.sorcery_config.instance_eval do
            @defaults.merge!(:@authentications_class                  => nil,
                             :@authentications_user_id_attribute_name => :user_id,
                             :@provider_attribute_name                => :provider,
                             :@provider_attribute_is_key              => :false,
                             :@providers_class                        => nil,
                             :@providers_class_attribute_name         => :name,
                             :@provider_uid_attribute_name            => :uid,
                             :@providers_class_require_email_on_save  => false,
                             :@providers_class_email_attribute_name   => :email)

            reset!
          end
          
          base.send(:include, InstanceMethods)
          base.extend(ClassMethods)

        end
        
        module ClassMethods

          # takes a provider and uid and finds a user by them.
          def load_from_provider(provider_name,uid)
            config = sorcery_config
            if not config.provider_attribute_is_key
              authentication = config.authentications_class.find_by_provider_and_uid(provider_name, uid)
            else
              provider = config.providers_class.find_by_name(provider_name.capitalize)
              authentication = config.authentications_class.where(config.provider_attribute_name => provider.id, config.provider_uid_attribute_name => uid).first if provider
            end
             user = find(authentication.send(config.authentications_user_id_attribute_name)) if authentication
          end
        end
        
        module InstanceMethods

        end
      
      end
    end
  end
end