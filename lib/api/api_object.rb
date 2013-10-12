module FellowshipOne

  # This class is the base class for all FellowshipOne objects and is meant to be inherited.
  #
  class ApiObject 
    attr_reader :error_messages, :marked_for_destruction
    

    # Used to specify a list of getters and setters.
    def self.f1_attr_accessor(*vars)
      @__f1_attributes ||= []
      @__f1_attributes.concat(vars)
      attr_accessor(*vars)
    end


    # A list of f1_attr_accessors that have been specified.
    def self.__f1_attributes
      @__f1_attributes
    end

    # Initializes the current object from the JSON data that was loaded into the Hash.
    #
    # @param object_attributes A Hash of values to load into the current object.
    def initialize_from_json_object(object_attributes)
      if object_attributes.is_a?( Hash )
        object_attributes.each do |key, value|
          
          method_to_call = "#{_attr_underscore(key.to_s)}="
          if method_to_call.chars.first == "@"
            method_to_call.reverse!.chop!.reverse!
          end

          if respond_to?(method_to_call)
            self.send(method_to_call, value) 
          end
          
        end
      end     
    end


    # # Returns the status of the current object.
    # def is_deleted?
    #   @_deleted ||= false
    # end
    
    # Gets the current object's attributes in a Hash.
    #
    # @return A hash of all the attributes.
    def to_attributes 
      vals = {}
      #vals = {:marked_for_destruction => self.is_deleted?} if self.is_deleted?
      self.class.__f1_attributes.each do |tca| 
        rep = self.send(tca)               
        if rep.class == Array   
          rep.collect! { |r| r.respond_to?(:to_attributes) ? r.to_attributes : r }
        end
        vals[_f1ize(tca)] = rep
      end
      _map_fields(vals)
      vals
    end


    # Sets the current object's attributes from a hash
    def set_attributes(attribute_data)
      attribute_data.each { |key, value| self.send("#{key}=", value) if self.respond_to?("#{key}=") }
    end


    # Save this object.
    #
    # @return True on success, otherwise false.
    def save
      writer = @writer_object.new(self.to_attributes) 
      result = writer.save_object
      if result === false
        @error_messages = writer.error_messages
      else
        self.set_attributes(result)
      end
      result === false ? false : true
    end


    # # Delete this object.
    # #
    # # @return True on success, otherwise false.
    # def delete
    #   writer = @writer_object.new(self.to_attributes) 
    #   result = writer.delete_object
    #   if result === false
    #     @error_messages = writer.error_messages
    #   else
    #     @_deleted = true
    #   end
    #   result === false ? false : true
    # end    


    # This method should be overwritten in the ApiObject subclass.
    def _field_map
      {}
    end

    private

    # Used for mapping FellowshipOne fields that may not match the naming or camelcase 
    # used, or that is generated.
    def _map_fields(fields)
      self._field_map.each do |key1, key2|
        fields[key2.to_s] = fields[key1.to_s]
        fields.delete(key1.to_s)
      end
    end


    def _attr_underscore(str)
      str.gsub(/::/, '/')
         .gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
         .gsub(/([a-z\d])([A-Z])/,'\1_\2')
         .tr("-", "_")
         .downcase
    end

    def _f1ize(term)
      term.to_s.split('_').inject([]) { |buffer, e| buffer.push(buffer.empty? ? e : e.capitalize) }.join 
    end
    
  end

end


