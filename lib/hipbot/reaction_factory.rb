module Hipbot
  class ReactionFactory < Struct.new(:reactable)
    attr_reader :current_description
    private :reactable, :current_description

    def build(options_stack, block)
      options = get_options(options_stack)
      block ||= options.delete(:block)
      @current_description = nil
      Reaction.new(reactable, options, block)
    end

    def description(text)
      @current_description = text
    end

    def get_reaction_options(params)
      options = params.extract_options!
      get_reaction_method_proc(params) do |block|
        options[:block] = block
      end
      options[:regexps] = params if params.any?
      options.merge(desc: current_description)
    end

    protected

    def get_reaction_method_proc(params)
      return unless params.last.kind_of?(Symbol)
      method_name = params.pop
      yield ->(*attributes){ plugin.send(method_name, *attributes) }
    end

    def get_options(stack)
      stack.inject{ |all, h| all.deep_merge(h) } || {}
    end
  end
end
