class Example
  
  def to_s
    
    # Comments at the start of will be collected with the comments below and
    # all notes and todos will be above even this.
    # @note that I want to tell you something
    # @todo this is a todo
    # This sentence was below the @note and the @todo but will appear with the
    # other sentences below them.
    self.to_s.capitalize
    
    # Some comments at the end that should get included as well
    
  end
  
  #
  # Create an xml representation of the specified class based on defined
  # HappyMapper elements and attributes. The method is defined in a way
  # that it can be called recursively by classes that are also HappyMapper
  # classes, allowg for the composition of classes.
  #
  # @param [Nokogiri::XML::Builder] builder an instance of the XML builder which
  #     is being used when called recursively.
  # @param [String] default_namespace the name of the namespace which is the
  #     default for the xml being produced; this is specified by the element
  #     declaration when calling #to_xml recursively.
  #
  # @return [String,Nokogiri::XML::Builder] return XML representation of the
  #      HappyMapper object; when called recursively this is going to return
  #      and Nokogiri::XML::Builder object.
  #
  def to_xml(builder = nil,default_namespace = nil)
    
    #
    # If {#to_xml} has been called without a passed in builder instance that
    # means we are going to return xml output. When it has been called with
    # a builder instance that means we most likely being called recursively
    # and will return the end product as a builder instance. 
    #
    unless builder
      write_out_to_xml = true
      builder = Nokogiri::XML::Builder.new
    end
    
    #
    # Find the attributes for the class and collect them into an array
    # that will be placed into a Hash structure
    #
    attributes = self.class.attributes.collect do |attribute|
      
      #
      # If an attribute is marked as read_only then we want to ignore the attribute
      # when it comes to saving the xml document; so we wiill not go into any of
      # the below process
      # 
      unless attribute.options[:read_only]
      
        value = send(attribute.method_name)
      
        #
        # If the attribute defines an on_save lambda/proc or value that maps to 
        # a method that the class has defined, then call it with the value as a
        # parameter.
        #
        if on_save_action = attribute.options[:on_save]
          if on_save_action.is_a?(Proc)
            value = on_save_action.call(value)
          elsif respond_to?(on_save_action)
            value = send(on_save_action,value)
          end
        end
      
        #
        # Attributes that have a nil value should be ignored unless they explicitly
        # state that they should be expressed in the output.
        #
        if value || attribute.options[:state_when_nil]
          attribute_namespace = attribute.options[:namespace] || default_namespace
          [ "#{attribute_namespace ? "#{attribute_namespace}:" : ""}#{attribute.tag}", value ]
        else
          []
        end
        
      else
        []
      end
      
    end.flatten
    
    attributes = Hash[ *attributes ]
  
    #
    # Create a tag in the builder that matches the class's tag name and append
    # any attributes to the element that were defined above.
    #
    builder.send(self.class.tag_name,attributes) do |xml|
      
      #
      # Add all the registered namespaces to the root element.
      # When this is called recurisvely by composed classes the namespaces
      # are still added to the root element
      # 
      # However, we do not want to add the namespace if the namespace is 'xmlns'
      # which means that it is the default namesapce of the code.
      #
      if self.class.instance_variable_get('@registered_namespaces') && builder.doc.root
        self.class.instance_variable_get('@registered_namespaces').each_pair do |name,href|
          name = nil if name == "xmlns"
          builder.doc.root.add_namespace(name,href)
        end
      end
      
      #
      # If the object we are persisting has a namespace declaration we will want
      # to use that namespace or we will use the default namespace.
      # When neither are specifed we are simply using whatever is default to the
      # builder
      #
      if self.class.respond_to?(:namespace) && self.class.namespace
        xml.parent.namespace = builder.doc.root.namespace_definitions.find do |x| 
          x.prefix == self.class.namespace
        end
      elsif default_namespace
        xml.parent.namespace = builder.doc.root.namespace_definitions.find do |x| 
          x.prefix == default_namespace
        end
      end
  
      
      #
      # When a text_node has been defined we add the resulting value
      # the output xml
      #
      if text_node = self.class.instance_variable_get('@text_node')
        
        unless text_node.options[:read_only]
          text_accessor = text_node.tag || text_node.name
          value = send(text_accessor)
        
          if on_save_action = text_node.options[:on_save]
            if on_save_action.is_a?(Proc)
              value = on_save_action.call(value)
            elsif respond_to?(on_save_action)
              value = send(on_save_action,value)
            end
          end
        
          builder.text(value)
        end
        
      end
  
      #
      # for every define element (i.e. has_one, has_many, element) we are
      # going to persist each one
      #
      self.class.elements.each do |element|
        
        #
        # If an element is marked as read only do not consider at all when 
        # saving to XML.
        # 
        unless element.options[:read_only]
          
          tag = element.tag || element.name
          
          #
          # The value to store is the result of the method call to the element,
          # by default this is simply utilizing the attr_accessor defined. However,
          # this allows for this method to be overridden
          #
          value = send(element.name)
  
          #
          # If the element defines an on_save lambda/proc then we will call that
          # operation on the specified value. This allows for operations to be 
          # performed to convert the value to a specific value to be saved to the xml.
          #
          if on_save_action = element.options[:on_save]
            if on_save_action.is_a?(Proc)
              value = on_save_action.call(value)
            elsif respond_to?(on_save_action)
              value = send(on_save_action,value)
            end 
          end
  
          # Normally a nil value would be ignored, however if specified then
          # an empty element will be written to the xml
          #
          if value.nil? && element.options[:single] && element.options[:state_when_nil]
            xml.send(tag,"")
          end
        
          #
          # To allow for us to treat both groups of items and singular items
          # equally we wrap the value and treat it as an array.
          #
          if value.nil?
            values = []
          elsif value.respond_to?(:to_ary) && !element.options[:single]
            values = value.to_ary
          else
            values = [value]
          end
        
          values.each do |item|
  
            if item.is_a?(HappyMapper)
  
              #
              # Other items are convertable to xml through the xml builder
              # process should have their contents retrieved and attached
              # to the builder structure
              #
              item.to_xml(xml,element.options[:namespace])
  
            elsif item
            
              item_namespace = element.options[:namespace] || default_namespace
            
              #
              # When a value exists we should append the value for the tag
              #
              if item_namespace
                xml[item_namespace].send(tag,item.to_s)
              else
                xml.send(tag,item.to_s)
              end
  
            else
  
              #
              # Normally a nil value would be ignored, however if specified then
              # an empty element will be written to the xml
              #
              xml.send(tag,"") if element.options[:state_when_nil]
  
            end
  
          end
          
        end
      end
  
    end
  
    write_out_to_xml ? builder.to_xml : builder
    
  end

end