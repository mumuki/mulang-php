require "spec_helper"

describe Mulang::PHP do
  include Mulang::PHP::Sexp

  describe '#parse' do
    let(:result) { convert_php_to_mulang ast }

    context 'functions' do
      context 'calls' do
        ###
        # asd("AAA");
        ###
        let(:ast) { %q{
          [
            {
              "nodeType": "Stmt_Expression",
              "expr": {
                "nodeType": "Expr_FuncCall",
                "name": {
                  "nodeType": "Name",
                  "parts": [
                    "asd"
                  ]
                },
                "args": [
                  {
                    "nodeType": "Arg",
                    "value": {
                      "nodeType": "Scalar_String",
                      "value": "AAA"
                    },
                    "byRef": false,
                    "unpack": false
                  }
                ]
              }
            }
          ]
        } }

        it {
          expect(result).to eq ms(
                                   :Application,
                                   ms(:Reference, 'asd'),
                                   [ms(:MuString, 'AAA')]
                               )
        }
      end

      context 'declarations' do
        ###
        # function aFunction($param1) { asd(); };
        ###
        let(:ast) { %q{
          [
            {
              "nodeType": "Stmt_Function",
              "byRef": false,
              "name": {
                "nodeType": "Identifier",
                "name": "aFunction"
              },
              "params": [
                {
                  "nodeType": "Param",
                  "type": null,
                  "byRef": false,
                  "variadic": false,
                  "var": {
                    "nodeType": "Expr_Variable",
                    "name": "param1"
                  },
                  "default": null
                }
              ],
              "returnType": null,
              "stmts": [
                {
                  "nodeType": "Stmt_Expression",
                  "expr": {
                    "nodeType": "Expr_FuncCall",
                    "name": {
                      "nodeType": "Name",
                      "parts": [
                        "asd"
                      ]
                    },
                    "args": []
                  }
                },
                {
                  "nodeType": "Stmt_Return",
                  "expr": {
                    "nodeType": "Scalar_LNumber",
                    "value": 32
                  }
                }
              ]
            }
          ]
        } }

        it {
          expect(result).to eq simple_function(
                                   'aFunction',
                                   [ms(:VariablePattern, 'param1')],
                                   sequence(
                                       ms(:Application, ms(:Reference, 'asd'), []),
                                       ms(:Return, ms(:MuNumber, 32))
                                   )
                               )
        }
      end
    end
  end
end