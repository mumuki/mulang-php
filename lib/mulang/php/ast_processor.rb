module Mulang::PHP
  class AstProcessor
    include AST::Sexp
    include Mulang::PHP::Sexp

    def initialize
      define_binary_operators!
    end

    def process_block(stmts)
      sequence *process(stmts)
    end

    def process(node)
      return ms(:None) if node.nil?

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

    def get_name(node)
      node[:parts].first
    end

    def define_binary_operators!
      [
        { token: '===', name: 'Identical', supports_assign?: false },
        { token: '!==', name: 'NotIdentical', supports_assign?: false },
        { token: '.', name: 'Concat', supports_assign?: true },
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
            binary_application "#{it[:token]}=", process(node[:var]), process(node[:expr])
          }
        end
      }
    end

    def process_binary_operator(operator, node)
      binary_application operator, process(node[:left]), process(node[:right])
    end

    # ---

    # VALUES

    def on_Stmt_Expression(node)
      process node[:expr]
    end

    def on_Expr_Variable(node)
      ms :Reference, node[:name]
    end

    def on_Scalar_DNumber(node)
      ms :MuNumber, node[:value]
    end
    alias on_Scalar_LNumber on_Scalar_DNumber

    def on_Scalar_String(node)
      ms :MuString, node[:value]
    end

    def on_Expr_ConstFetch(node)
       value = get_name(node[:name]).downcase

      case value
        when 'true'
          ms :MuBool, true
        when 'false'
          ms :MuBool, false
        when 'null'
          ms :MuNil
        else
          ms :Reference, value
      end
    end

    def on_Expr_Array(node)
      items = node[:items]
      is_array = items.all? { |it| it[:key].nil? }

      is_array ? ms(:MuList, process(items))
               : ms(:MuObject, process_block(items))
    end

    def on_Expr_ArrayItem(node)
      value = process(node[:value])

      node[:key] ? ms(:Attribute, node[:key][:value].to_s, value)
                 : value
    end

    def on_Expr_Closure(node)
      ms :Lambda, process(node[:params]), process_block(node[:stmts])
    end

    def on_Param(node)
      ms :VariablePattern, node[:var][:name]
    end

    # OPERATORS

    def on_Expr_BinaryOp_Equal(node)
      ms :Application, [primitive(:Equal), [process(node[:left]), process(node[:right])]]
    end

    def on_Expr_BinaryOp_NotEqual(node)
      ms :Application, [primitive(:NotEqual), [process(node[:left]), process(node[:right])]]
    end

    def on_Expr_PostInc(node)
      binary_application '+', process(node[:var]), ms(:MuNumber, 1)
    end
    alias on_Expr_PreInc on_Expr_PostInc

    def on_Expr_PostDec(node)
      binary_application '-', process(node[:var]), ms(:MuNumber, 1)
    end
    alias on_Expr_PreDec on_Expr_PostDec

    # FUNCTION CALLS

    def on_Expr_FuncCall(node)
      application get_name(node[:name]), process(node[:args])
    end

    def on_Arg(node)
      process node[:value]
    end

    # DECLARATIONS

    def on_Stmt_Function(node)
      simple_function node[:name][:name], process(node[:params]), process_block(node[:stmts])
    end

    def on_Stmt_Return(node)
      ms :Return, process(node[:expr])
    end

    # STATEMENTS

    def on_Expr_Assign(node)
      left = node[:var]
      exp = process(node[:expr])

      if left[:nodeType] == 'Expr_PropertyFetch'
        simple_send process(left[:var]), "#{left[:name][:name]}=", [exp]
      else
        ms :Assignment, left[:name], exp
      end
    end

    def on_Stmt_Echo(node)
      ms :Print, process_block(node[:exprs])
    end

    def on_Stmt_If(node)
      condition = node[:cond]
      body = node[:stmts]
      else_block = node[:else]

      ms :If, process(condition), process_block(body), process(else_block)
    end
    alias on_Stmt_ElseIf on_Stmt_If

    def on_Stmt_Else(node)
      process_block node[:stmts]
    end

    def on_Stmt_For(node)
      ms :ForLoop, process_block(node[:init]), process_block(node[:cond]), process_block(node[:loop]), process_block(node[:stmts])
    end

    def on_Stmt_While(node)
      ms :While, process(node[:cond]), process_block(node[:stmts])
    end

    def on_Stmt_Foreach(node)
      ms :For, [ms(:Generator, ms(:VariablePattern, node[:valueVar][:name]), process(node[:expr]))], process_block(node[:stmts])
    end

    # OOP

    def on_Expr_PropertyFetch(node)
      simple_send process(node[:var]), node[:name][:name], []
    end

    def on_Expr_MethodCall(node)
      simple_send process(node[:var]), node[:name][:name], process(node[:args])
    end

    def on_Expr_New(node)
      ms :New, process(node[:class]), process(node[:args])
    end

    def on_Name(node)
      ms :Reference, get_name(node)
    end

    def on_Stmt_Class(node)
      superclass = node.dig(:extends, :parts)&.first
      interfaces = node[:implements].map { |it| { nodeType: 'Stmt_Implement', name: get_name(it) } }

      ms :Class, node[:name][:name], superclass, process_block(interfaces.concat(node[:stmts]))
    end

    def on_Stmt_Implement(node)
      ms :Implement, ms(:Reference, node[:name])
    end

    def on_Stmt_Property(node)
      prop = node[:props].first
      ms :Attribute, prop[:name][:name], process(prop[:default])
    end

    def on_Stmt_ClassMethod(node)
      name = node[:name][:name]
      params = process(node[:params])

      if node[:stmts].nil?
        ms :TypeSignature, name, ms(:ParameterizedType, params.map { |it| 'Any' }, 'Any', [])
      else
        simple_method name, params, process_block(node[:stmts])
      end
    end

    def on_Stmt_Interface(node)
      parents = node[:extends].map { |it| get_name(it) }
      ms :Interface, node[:name][:name], parents, process_block(node[:stmts])
    end

    def method_missing(m, *args, &block)
      puts m, args
      ms :Other, "#{m}: #{args.to_s}", nil
    end
  end
end
