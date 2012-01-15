module Mixcloud
  class Resource
    include Mixcloud::UrlFixer

    def initialize(url)
      url_with_metadata = concat_with_metadata(url)
      data_hash = JSON.parse RestClient.get(url_with_metadata)
      klass =  Mixcloud.const_get(data_hash['type'].capitalize)
      prevent_url_and_class_mismatch(klass)
      map_to_resource_attributes(data_hash)

      # resource.each_pair do |key, value|
      #   create_picture_urls(value) if key == 'pictures'
      # 
      #   if Mixcloud.const_defined?(key.capitalize)
      #     key = key + "_url"
      #     value = value['url'].gsub('http://www.', 'http://api.') + "?metadata=1"
      #     self.class.send(:define_method, key ) do
      #       value
      #     end
      #     next
      #   end
      # 
      #   unless ['metadata', 'sections', 'pictures', 'tags'].include?(key)
      #     send("#{key}=", value) 
      #   end
      # end

    end


    ###########################################
    private

    def prevent_url_and_class_mismatch(klass)
      if klass != self.class
        raise "You tried to create an object of #{self.class} with an URL of object type #{klass}"
      end
    end

    def map_to_resource_attributes(data_hash)
      data_hash.each_pair do | key, value |
        create_picture_url_methods(value) if key == 'pictures'
        if Mixcloud.const_defined?(key.capitalize)
          create_associated_object_url_methods(key, value)
          next
        end
        assign_values_to_attribues(key, value)
      end
    end

    def create_picture_url_methods(picture_hash)
      picture_hash.each_pair do |format, picture_url|
        self.class.send(:define_method, "#{format}_picture_url") { picture_url }
      end
    end

    def create_associated_object_url_methods(key, value)
      method_name = key + "_url"
      object_url = value['url'].gsub('http://www.', 'http://api.') + "?metadata=1"
      self.class.send(:define_method, method_name ) { object_url}
    end

    def assign_values_to_attribues(key, value)
      unless ['metadata', 'sections', 'pictures', 'tags', 'type'].include?(key)
        send("#{key}=", value) 
      end
    end

    ############################################
  end
end