class XbuilderTemplate < Xbuilder
  def self.encode(context)
    xml = self.new
    xml.__instance_variable_set(:@context, context)
    yield xml
    xml.target!
  end

  def partial!(options, locals = {})
    case options
    when Hash
      options[:locals] ||= {}
      options[:locals].merge!(xml: self)
      @context.render(options)
    else
      @context.render(options, locals.merge(xml: self))
    end
  end

  protected

  def __new_instance(*args)
    new_instance = super
    new_instance.__set_context(@context)
    new_instance
  end

  def __set_context(context)
    @context = context
  end

end

class XbuilderHandler
  cattr_accessor :default_format
  self.default_format = Mime::XML

  def self.call(template)
    %[
      if defined?(xml)
        #{template.source}
      else
        XbuilderTemplate.encode(self) do |xml|
          #{template.source}
        end
      end
    ]
  end
end

ActionView::Template.register_template_handler :xbuilder, XbuilderHandler
