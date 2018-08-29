module Mulang::PHP
  module Sexp
    def sequence(*contents)
      if contents.empty?
        ms(:None)
      elsif contents.size == 1
        contents[0]
      else
        ms(:Sequence, *contents)
      end
    end

    def ms(tag, *contents)
      if contents.empty?
        {tag: tag}
      elsif contents.size == 1
        {tag: tag, contents: contents.first}
      else
        {tag: tag, contents: contents}
      end
    end

    def simple_function(name, args, body)
      callable :Function, name, args, body
    end

    def simple_method(name, args, body)
      callable :Method, name, args, body
    end

    def callable(type, name, args, body)
      {
          tag: type,
          contents: [
              name,
              [
                  [ args, {tag: :UnguardedBody, contents: body }]
              ]
          ]
      }
    end

    def application(name, args)
      ms :Application, [ms(:Reference, name), args]
    end

    def binary_operator(operator, left, right)
      application operator, [left, right]
    end

    def simple_send(sender, message, args)
      ms(:Send, sender, ms(:Reference, message), args)
    end
  end
end
