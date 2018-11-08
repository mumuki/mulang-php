require "spec_helper"

describe Mulang::PHP do
  include Mulang::PHP::Sexp

  it "has a version number" do
    expect(Mulang::PHP::VERSION).not_to be nil
  end

  describe '#parse' do
    let(:result) { convert_php_to_mulang ast }

    context 'values' do
      context 'integer' do
        ###
        # 2;
        ###
        let(:ast) { %q{
          [
            {
              "nodeType": "Stmt_Expression",
              "expr": {
                "nodeType": "Scalar_LNumber",
                "value": 2
              }
            }
          ]
        } }

        it { expect(result).to eq ms :MuNumber, 2 }
      end

      context 'floats' do
        ###
        # 2.3;
        ###
        let(:ast) { %q{
          [
            {
              "nodeType": "Stmt_Expression",
              "expr": {
                "nodeType": "Scalar_DNumber",
                "value": 2.3
              }
            }
          ]
        } }

        it { expect(result).to eq ms :MuNumber, 2.3 }
      end

      context 'strings' do
        ###
        # "Hi, I'm a string.";
        ###
        let(:ast) { %q{
          [
            {
              "nodeType": "Stmt_Expression",
              "expr": {
                "nodeType": "Scalar_String",
                "value": "Hi, I'm a string."
              }
            }
          ]
        } }

        it { expect(result).to eq ms :MuString, "Hi, I'm a string." }
      end

      context 'booleans' do
        let(:ast) {
          JSON.generate([
            {
              'nodeType': 'Stmt_Expression',
              'expr': {
                'nodeType': 'Expr_ConstFetch',
                'name': {
                  'nodeType': 'Name',
                  'parts': [
                    boolean
                  ]
                }
              }
            }
          ])
        }

        context 'true' do
          ###
          # true;
          ###
          let(:boolean) { "true" }

          it { expect(result).to eq ms :MuBool, true }
        end

        context 'false' do
          ###
          # false;
          ###
          let(:boolean) { "false" }

          it { expect(result).to eq ms :MuBool, false }
        end
      end

      context 'nulls' do
        ###
        # null;
        ###
        let(:ast) { %q{
          [
            {
              "nodeType": "Stmt_Expression",
              "expr": {
                "nodeType": "Expr_ConstFetch",
                "name": {
                  "nodeType": "Name",
                  "parts": [
                    "null"
                  ]
                }
              }
            }
          ]
        } }

        it { expect(result).to eq ms :MuNil }
      end

      context 'arrays' do
        context 'empty' do
          ###
          # [];
          ###
          let(:ast) { %q{
            [
              {
                "nodeType": "Stmt_Expression",
                "expr": {
                  "nodeType": "Expr_Array",
                  "items": []
                }
              }
            ]
           } }

          it { expect(result).to eq ms :MuList, [] }
        end

        context 'non-empty' do
          ###
          # [1, "dos", true];
          ###
          let(:ast) { %q{
            [
              {
                "nodeType": "Stmt_Expression",
                "expr": {
                  "nodeType": "Expr_Array",
                  "items": [
                    {
                      "nodeType": "Expr_ArrayItem",
                      "key": null,
                      "value": {
                        "nodeType": "Scalar_LNumber",
                        "value": 1
                      },
                      "byRef": false
                    },
                    {
                      "nodeType": "Expr_ArrayItem",
                      "key": null,
                      "value": {
                        "nodeType": "Scalar_String",
                        "value": "dos"
                      },
                      "byRef": false
                    },
                    {
                      "nodeType": "Expr_ArrayItem",
                      "key": null,
                      "value": {
                        "nodeType": "Expr_ConstFetch",
                        "name": {
                          "nodeType": "Name",
                          "parts": [
                            "true"
                          ]
                        }
                      },
                      "byRef": false
                    }
                  ]
                }
              }
            ]
          } }

          it {
            expect(result).to eq ms(
                                     :MuList,
                                     ms(:MuNumber, 1),
                                     ms(:MuString, 'dos'),
                                     ms(:MuBool, true)
                                 )
          }
        end
      end

      context 'associative arrays' do
        ###
        # [ "foo" => "bar", "baz" => "faz" ];
        ###
        let(:ast) { %q{
          [
            {
              "nodeType": "Stmt_Expression",
              "expr": {
                "nodeType": "Expr_Array",
                "items": [
                  {
                    "nodeType": "Expr_ArrayItem",
                    "key": {
                      "nodeType": "Scalar_String",
                      "value": "foo"
                    },
                    "value": {
                      "nodeType": "Scalar_String",
                      "value": "bar"
                    },
                    "byRef": false
                  },
                  {
                    "nodeType": "Expr_ArrayItem",
                    "key": {
                      "nodeType": "Scalar_String",
                      "value": "baz"
                    },
                    "value": {
                      "nodeType": "Scalar_LNumber",
                      "value": 5
                    },
                    "byRef": false
                  }
                ]
              }
            }
          ]
        } }

        it { expect(result).to eq ms :MuObject, sequence(
            ms(:Attribute, 'foo', ms(:MuString, 'bar')),
            ms(:Attribute, 'baz', ms(:MuNumber, 5))
        ) }
      end

      context 'lambdas' do
        ###
        # function($param1) { asd(); };
        ###
        let(:ast) { %q{
          [
            {
              "nodeType": "Stmt_Expression",
              "expr": {
                "nodeType": "Expr_Closure",
                "static": false,
                "byRef": false,
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
                "uses": [],
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
                  }
                ]
              }
            }
          ]
          } }

        it {
          expect(result).to eq ms(
                                   :Lambda,
                                   [ms(:VariablePattern, 'param1')],
                                   ms(:Application, ms(:Reference, 'asd'), [])
                               )
        }
      end
    end
  end
end
