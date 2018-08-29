module Mulang::PHP
  class AstProcessor
    include AST::Sexp
    include Mulang::PHP::Sexp

    def initialize
      define_binary_operators!
    end

    def process_ast(ast)
      process sequence(*ast)
    end

    def process(node)
      if node.is_a?(Array)
        return node.map { |it| process it }
      end

      if node.is_a?(Hash)
        return send "on_#{node[:nodeType]}", node
      end

      ms(:Other)
    end

    def process_array(array, &f)
      array.map f
    end

    def define_binary_operators!
      [
        { token: '===', name: 'Identical', supports_assign?: false },
        { token: '!==', name: 'NotIdentical', supports_assign?: false },
        { token: '+', name: 'Plus', supports_assign?: true },
        { token: '-', name: 'Minus', supports_assign?: true },
        { token: '*', name: 'Mul', supports_assign?: true },
        { token: '/', name: 'Div', supports_assign?: true },
        { token: '%', name: 'Mod', supports_assign?: true },
        { token: '**', name: 'Pow', supports_assign?: true },
        { token: '>', name: 'Greater', supports_assign?: false },
        { token: '<', name: 'Smaller', supports_assign?: false },
        { token: '>=', name: 'GreaterOrEqual', supports_assign?: false },
        { token: '<=', name: 'SmallerOrEqual', supports_assign?: false },
        { token: '&', name: 'BitwiseAnd', supports_assign?: true },
        { token: '|', name: 'BitwiseOr', supports_assign?: true },
        { token: '&&', name: 'BooleanAnd', supports_assign?: false },
        { token: '||', name: 'BooleanOr', supports_assign?: false },
        { token: 'and', name: 'LogicalAnd', supports_assign?: false },
        { token: 'or', name: 'LogicalOr', supports_assign?: false },
        { token: 'xor', name: 'LogicalXOr', supports_assign?: false }
      ].each { |it|
        self.class.redefine_method(:"on_Expr_BinaryOp_#{it[:name]}") { |node|
          process_binary_operator it[:token], node
        }

        if it[:supports_assign?]
          self.class.redefine_method(:"on_Expr_AssignOp_#{it[:name]}") { |node|
            binary_operator "#{it[:token]}=", process(node[:var]), process(node[:expr])
          }
        end
      }
    end

    def process_binary_operator(operator, node)
      binary_operator operator, process(node[:left]), process(node[:right])
    end

    # ---

    def on_Stmt_Expression(node)
      process(node[:expr])
    end

    def on_Expr_Variable(node)
      ms :Reference, node[:name]
    end

    def on_Expr_Assign(node)
      ms :Assignment, node[:var][:name], process(node[:expr])
    end

    def on_Scalar_DNumber(node)
      ms :MuNumber, node[:value]
    end
    alias on_Scalar_LNumber on_Scalar_DNumber

    def on_Scalar_String(node)
      ms :MuString, node[:value]
    end

    def on_Expr_ConstFetch(node)
      return ms :Other if node[:name][:nodeType] != 'Name'

      value = node[:name][:parts].first.downcase

      case value
        when 'true'
          ms :MuBool, true
        when 'false'
          ms :MuBool, false
        when 'null'
          ms :None
        else
          ms :Reference, value
      end
    end

    def on_Expr_Array(node)
      items = node[:items]
      is_array = items.all? { |it| it[:key].nil? }

      is_array ? ms(:MuList, process(items))
               : ms(:MuObject, sequence(*process(items)))
    end

    def on_Expr_ArrayItem(node)
      value = process(node[:value])

      node[:key] ? ms(:Attribute, node[:key][:value].to_s, value)
                 : value
    end

    def on_Expr_BinaryOp_Equal(node)
      ms :Equal, [process(node[:left]), process(node[:right])]
    end

    def on_Expr_BinaryOp_NotEqual(node)
      ms :NotEqual, [process(node[:left]), process(node[:right])]
    end

    def on_Expr_PostInc(node)
      binary_operator '+', process(node[:var]), ms(:MuNumber, 1)
    end
    alias on_Expr_PreInc on_Expr_PostInc

    def on_Expr_PostDec(node)
      binary_operator '-', process(node[:var]), ms(:MuNumber, 1)
    end
    alias on_Expr_PreDec on_Expr_PostDec

    def on_Stmt_Echo(node)
      ms :Print, sequence(*process(node[:exprs]))
    end

    # def on_class(node)
    #   name, superclass, body = *node
    #   body ||= s(:nil)
    #
    #   _, class_name = *name
    #   _, superclass_name = *superclass
    #
    #   ms :Class, class_name, superclass_name, process(body)
    # end
    #
    # def on_module(node)
    #   name, body = *node
    #   body ||= s(:nil)
    #
    #   _, module_name = *name
    #
    #   ms :Object, module_name, process(body)
    # end
    #
    # def on_begin(node)
    #   sequence(*process_all(node))
    # end
    #
    # def on_rescue(node)
    #   try, *catch, _ = *node
    #   ms :Try, process(try), process_all(catch), ms(:MuNil)
    # end
    #
    # def on_resbody(node)
    #   patterns, variable, block = *node
    #
    #   [to_mulang_pattern(patterns, variable), process(block) || ms(:MuNil)]
    # end
    #
    # def _
    #   Object.new.tap { |it| it.define_singleton_method(:==) { |_| true } }
    # end
    #
    # def to_mulang_pattern(patterns, variable)
    #   case [patterns, variable]
    #     when [nil, nil]
    #       ms :WildcardPattern
    #     when [nil, _]
    #       ms :VariablePattern, variable.to_a.first
    #     when [_, nil]
    #       to_single_pattern patterns
    #     else
    #       ms(:AsPattern, variable.to_a.first, to_single_pattern(patterns))
    #   end
    # end
    #
    # def to_single_pattern(patterns)
    #   mu_patterns = patterns.to_a.map { |it| to_type_pattern it }
    #   mu_patterns.size == 1 ? mu_patterns.first : ms(:UnionPattern, mu_patterns)
    # end
    #
    # def to_type_pattern(node)
    #   _, type = *node
    #   ms :TypePattern, type
    # end
    #
    # def on_kwbegin(node)
    #   process node.to_a.first
    # end
    #
    # def on_ensure(node)
    #   catch, finally = *node
    #   try, catches = on_rescue(catch)[:contents]
    #   ms :Try, try, catches, process(finally)
    # end
    #
    # def on_irange(node)
    #   ms :Other, node.to_s, nil
    # end
    #
    # def on_regexp(node)
    #   value, _ops = *node
    #
    #   simple_send ms(:Reference, :Regexp), :new, [process(value)]
    # end
    #
    # def on_dstr(node)
    #   parts = *node
    #
    #   simple_send ms(:MuList, process_all(parts)), :join, []
    # end
    #
    # def on_or(node)
    #   value, other = *node
    #   simple_send process(value), '||', [process(other)]
    # end
    #
    # def on_and(node)
    #   value, other = *node
    #
    #   simple_send process(value), '&&', [process(other)]
    # end
    #
    # def on_return(node)
    #   value = *node
    #
    #   ms(:Return, process(value.first))
    # end
    #
    # def on_defs(node)
    #   _target, id, args, body = *node
    #   body ||= s(:nil)
    #
    #   simple_method id, process_all(args), process(body)
    # end
    #
    # def on_def(node)
    #   id, args, body = *node
    #   body ||= s(:nil)
    #
    #   case id
    #   when :equal?, :eql?, :==
    #     mu_method :EqualMethod, process_all(args), process(body)
    #   when :hash
    #     mu_method :HashMethod, process_all(args), process(body)
    #   else
    #     simple_method id, process_all(args), process(body)
    #   end
    # end
    #
    # def on_block(node)
    #   send, parameters, body = *node
    #   lambda = ms(:Lambda, process_all(parameters), process(body))
    #   handle_send_with_args send, [lambda]
    # end
    #
    # def on_send(node)
    #   handle_send_with_args(node)
    # end
    #
    # def on_nil(_)
    #   ms :MuNil
    # end
    #
    # def on_self(_)
    #   ms :Self
    # end
    #
    # def on_arg(node)
    #   name, _ = *node
    #   ms :VariablePattern, name
    # end
    #
    # alias on_restarg on_arg
    # alias on_procarg0 on_arg
    #
    # def on_str(node)
    #   value, _ = *node
    #   ms :MuString, value
    # end
    #
    # def on_sym(node)
    #   value, _ = *node
    #   ms :MuSymbol, value.to_s
    # end
    #
    # def on_float(node)
    #   value, _ = *node
    #   ms :MuNumber, value
    # end
    #
    # alias on_int on_float
    #
    # def on_if(node)
    #   condition, if_true, if_false = *node
    #   if_true  ||= s(:nil)
    #   if_false ||= s(:nil)
    #
    #   ms :If, process(condition), process(if_true), process(if_false)
    # end
    #
    # def on_lvar(node)
    #   value = *node
    #   ms :Reference, value.first
    # end
    #
    # def on_lvasgn(node)
    #   id, value = *node
    #   ms :Assignment, id, process(value)
    # end
    #
    # def on_casgn(node)
    #   _ns, id, value = *node
    #   ms :Assignment, id, process(value)
    # end
    #
    # def on_op_asgn(node)
    #   assignee, message, value = *node
    #
    #   if assignee.type == :send
    #     property_assignment assignee, message, value
    #   else
    #     var_assignment assignee, message, value
    #   end
    # end
    #
    # def var_assignment(assignee, message, value)
    #   id = assignee.to_a.first
    #   ms :Assignment, id, simple_send(ms(:Reference, id), message, [process(value)])
    # end
    #
    # def property_assignment(assignee, message, value)
    #   receiver, accessor, *accessor_args = *assignee
    #
    #   reasign accessor, process_all(accessor_args), process(receiver), message, process(value)
    # end
    #
    # def reasign(accessor, args, id, message, value)
    #   simple_send id,
    #               "#{accessor}=".to_sym,
    #               args + [simple_send(
    #                         simple_send(id, accessor, args),
    #                         message,
    #                         [value])]
    # end
    #
    # def on_or_asgn(node)
    #   assignee, value = *node
    #   on_op_asgn s :op_asgn, assignee, '||', value
    # end
    #
    # def on_and_asgn(node)
    #   assignee, value = *node
    #   on_op_asgn s :op_asgn, assignee, '&&', value
    # end
    #
    # alias on_ivar on_lvar
    # alias on_ivasgn on_lvasgn
    #
    # def on_const(node)
    #   _ns, value = *node
    #   ms :Reference, value
    # end
    #
    # def on_true(_)
    #   ms :MuBool, true
    # end
    #
    # def on_false(_)
    #   ms :MuBool, false
    # end
    #
    # def on_array(node)
    #   elements = *node
    #   {tag: :MuList, contents: process_all(elements)}
    # end
    #
    # def handler_missing(*args)
    #   puts args
    #   ms :Other, args.to_s, nil
    # end
    #
    # def handle_send_with_args(node, extra_args=[])
    #   receptor, message, *args = *node
    #   receptor ||= s(:self)
    #
    #   if message == :==
    #     message = {tag: :Equal}
    #   elsif message == :!=
    #     message = {tag: :NotEqual}
    #   else
    #     message = {tag: :Reference, contents: message}
    #   end
    #
    #   ms :Send, process(receptor), message, (process_all(args) + extra_args)
    # end

    # TODO: Recuperar
    # def method_missing(m, *args, &block)
    #   ms :Other
    # end
  end
end
