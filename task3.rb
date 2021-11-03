class MDHtml
    attr_accessor :result, :indents
    SELF_CLOSING_TAGS = %i(area base br col embed iframe hr img input link meta param source track wbr command keygen menuitem)

    def initialize(&block)
        @indents = 0
        @result = ""
        instance_eval(&block)
    end

    def to_s
        @result
    end

    private

    def method_missing(name, *args, &block)     
        tag = name.to_s
        
        options = combine_options(find_options(args))
        content = find_content(args)

        if(tag == "html") 
            @result << "<!doctype html>"
        end
        
        @result << "\n#{add_indent}<#{tag}#{options}>#{content}"

        if block_given?
            @indents += 1

            context = instance_eval(&block)
            
            if context.is_a?(String) && (tag == "div")
                @result << "\n#{add_indent}#{context}"
            end

            @indents -= 1
            @result << "\n#{add_indent}"
        end
        
        unless SELF_CLOSING_TAGS.member?(name)
            @result << "</#{tag}>"
        end
    end
    
    def find_content(args)
        args.detect{|arg| arg.is_a?(String)}
    end
    
    def find_options(args)
        args.detect{|arg| arg.is_a?(Hash)} || {}
    end

    def combine_options(options)
        options.collect{|key, value| " #{key}=\"#{value}\""}.join("")
    end

    def add_indent
        " " * indents
    end
  
end

page = MDHtml.new do
    html do
        head do
            meta charset: "utf-8"
            title "The HTML5 Template"
            meta description: "The HTML5 Template"
            meta author: "MobiDev"
            link stylesheet: "css/styles.css?v=1.0"
        end
            
        body do
            div do
                "Hello World"
            end
            script src:"js/scripts.js"
        end
    end
end

puts(page.to_s)