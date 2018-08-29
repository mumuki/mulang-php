require "spec_helper"

# def try(catches, finally)
#   simple_method(:foo, [],
#     ms(:Try,
#       simple_send(
#         ms(:Self),
#         :bar,
#         []), catches, finally))
# end

describe Mulang::PHP do
  include Mulang::PHP::Sexp

  describe '#parse' do
    let(:result) { convert_php_to_mulang ast }

    context 'OOP' do
      context 'property fetch' do
        ###
        # $this->nigiri;
        ###
        let(:ast) { %q{
          [
            {
              "nodeType": "Stmt_Expression",
              "expr": {
                "nodeType": "Expr_PropertyFetch",
                "var": {
                  "nodeType": "Expr_Variable",
                  "name": "this"
                },
                "name": {
                  "nodeType": "Identifier",
                  "name": "nigiri"
                }
              }
            }
          ]
        } }

        it { expect(result).to eq simple_send(ms(:Reference, 'this'), 'nigiri', []) }
      end
    end

    context 'property assignment' do
      ###
      # $obje->prop = 'value';
      ###
      let(:ast) { %q{
        [
          {
            "nodeType": "Stmt_Expression",
            "expr": {
              "nodeType": "Expr_Assign",
              "var": {
                "nodeType": "Expr_PropertyFetch",
                "var": {
                  "nodeType": "Expr_Variable",
                  "name": "obje"
                },
                "name": {
                  "nodeType": "Identifier",
                  "name": "prop"
                }
              },
              "expr": {
                "nodeType": "Scalar_String",
                "value": "value"
              }
            }
          }
        ]
        } }

      it { expect(result).to eq simple_send(ms(:Reference, 'obje'), 'prop=', [ms(:MuString, 'value')]) }
    end

    context 'method call' do
      ###
      # $obj->metodo(1, 2);
      ###
      let(:ast) { %q{
        [
          {
            "nodeType": "Stmt_Expression",
            "expr": {
              "nodeType": "Expr_MethodCall",
              "var": {
                "nodeType": "Expr_Variable",
                "name": "obj"
              },
              "name": {
                "nodeType": "Identifier",
                "name": "metodo"
              },
              "args": [
                {
                  "nodeType": "Arg",
                  "value": {
                    "nodeType": "Scalar_LNumber",
                    "value": 1
                  },
                  "byRef": false,
                  "unpack": false
                },
                {
                  "nodeType": "Arg",
                  "value": {
                    "nodeType": "Scalar_LNumber",
                    "value": 2
                  },
                  "byRef": false,
                  "unpack": false
                }
              ]
            }
          }
        ]
      } }

      it { expect(result).to eq simple_send(ms(:Reference, 'obj'), 'metodo', [ms(:MuNumber, 1), ms(:MuNumber, 2)]) }
    end

    context 'new operator' do
      ###
      # new Cosa("arg");
      ###
      let(:ast) { %q{
        [
          {
            "nodeType": "Stmt_Expression",
            "expr": {
              "nodeType": "Expr_New",
              "class": {
                "nodeType": "Name",
                "parts": [
                  "Cosa"
                ]
              },
              "args": [
                {
                  "nodeType": "Arg",
                  "value": {
                    "nodeType": "Scalar_String",
                    "value": "arg"
                  },
                  "byRef": false,
                  "unpack": false
                }
              ]
            }
          }
        ]
      } }

      it { expect(result).to eq ms(:New, ms(:Reference, 'Cosa'), [ms(:MuString, 'arg')]) }
    end

    context 'class' do
      ###
      # class Vegetable {
      #   var $edible;
      #   var $color;
      #
      #   function __construct($edible, $color = "green") {
      #     $this->edible = $edible;
      #     $this->color = $color;
      #   }
      #
      #   function is_edible() {
      #     return $this->edible;
      #   }
      #
      #   function what_color() {
      #     return $this->color;
      #   }
      # }
      ###
      let(:ast) { %q{
        [
          {
            "nodeType": "Stmt_Class",
            "flags": 0,
            "extends": null,
            "implements": [],
            "name": {
              "nodeType": "Identifier",
              "name": "Vegetable"
            },
            "stmts": [
              {
                "nodeType": "Stmt_Property",
                "flags": 0,
                "props": [
                  {
                    "nodeType": "Stmt_PropertyProperty",
                    "name": {
                      "nodeType": "VarLikeIdentifier",
                      "name": "edible"
                    },
                    "default": null
                  }
                ]
              },
              {
                "nodeType": "Stmt_Property",
                "flags": 0,
                "props": [
                  {
                    "nodeType": "Stmt_PropertyProperty",
                    "name": {
                      "nodeType": "VarLikeIdentifier",
                      "name": "color"
                    },
                    "default": null
                  }
                ]
              },
              {
                "nodeType": "Stmt_ClassMethod",
                "flags": 0,
                "byRef": false,
                "name": {
                  "nodeType": "Identifier",
                  "name": "__construct"
                },
                "params": [
                  {
                    "nodeType": "Param",
                    "type": null,
                    "byRef": false,
                    "variadic": false,
                    "var": {
                      "nodeType": "Expr_Variable",
                      "name": "edible"
                    },
                    "default": null
                  },
                  {
                    "nodeType": "Param",
                    "type": null,
                    "byRef": false,
                    "variadic": false,
                    "var": {
                      "nodeType": "Expr_Variable",
                      "name": "color"
                    },
                    "default": {
                      "nodeType": "Scalar_String",
                      "value": "green"
                    }
                  }
                ],
                "returnType": null,
                "stmts": [
                  {
                    "nodeType": "Stmt_Expression",
                    "expr": {
                      "nodeType": "Expr_Assign",
                      "var": {
                        "nodeType": "Expr_PropertyFetch",
                        "var": {
                          "nodeType": "Expr_Variable",
                          "name": "this"
                        },
                        "name": {
                          "nodeType": "Identifier",
                          "name": "edible"
                        }
                      },
                      "expr": {
                        "nodeType": "Expr_Variable",
                        "name": "edible"
                      }
                    }
                  },
                  {
                    "nodeType": "Stmt_Expression",
                    "expr": {
                      "nodeType": "Expr_Assign",
                      "var": {
                        "nodeType": "Expr_PropertyFetch",
                        "var": {
                          "nodeType": "Expr_Variable",
                          "name": "this"
                        },
                        "name": {
                          "nodeType": "Identifier",
                          "name": "color"
                        }
                      },
                      "expr": {
                        "nodeType": "Expr_Variable",
                        "name": "color"
                      }
                    }
                  }
                ]
              },
              {
                "nodeType": "Stmt_ClassMethod",
                "flags": 0,
                "byRef": false,
                "name": {
                  "nodeType": "Identifier",
                  "name": "is_edible"
                },
                "params": [],
                "returnType": null,
                "stmts": [
                  {
                    "nodeType": "Stmt_Return",
                    "expr": {
                      "nodeType": "Expr_PropertyFetch",
                      "var": {
                        "nodeType": "Expr_Variable",
                        "name": "this"
                      },
                      "name": {
                        "nodeType": "Identifier",
                        "name": "edible"
                      }
                    }
                  }
                ]
              },
              {
                "nodeType": "Stmt_ClassMethod",
                "flags": 0,
                "byRef": false,
                "name": {
                  "nodeType": "Identifier",
                  "name": "what_color"
                },
                "params": [],
                "returnType": null,
                "stmts": [
                  {
                    "nodeType": "Stmt_Return",
                    "expr": {
                      "nodeType": "Expr_PropertyFetch",
                      "var": {
                        "nodeType": "Expr_Variable",
                        "name": "this"
                      },
                      "name": {
                        "nodeType": "Identifier",
                        "name": "color"
                      }
                    }
                  }
                ]
              }
            ]
          }
        ]
      } }

      it {
        expect(result).to eq ms(
                                 :Class,
                                 'Vegetable',
                                 nil,
                                 sequence(
                                     ms(:Attribute, 'edible', ms(:None)),
                                     ms(:Attribute, 'color', ms(:None)),
                                     simple_method(
                                         '__construct',
                                         [ms(:VariablePattern, 'edible'), ms(:VariablePattern, 'color')],
                                         sequence(
                                             ms(:Send, ms(:Reference, 'this'), ms(:Reference, 'edible='), [ms(:Reference, 'edible')]),
                                             ms(:Send, ms(:Reference, 'this'), ms(:Reference, 'color='), [ms(:Reference, 'color')]),
                                         )
                                     ),
                                     simple_method(
                                         'is_edible',
                                         [],
                                         ms(:Return, ms(:Send, ms(:Reference, 'this'), ms(:Reference, 'edible'), []))
                                     ),
                                     simple_method(
                                         'what_color',
                                         [],
                                         ms(:Return, ms(:Send, ms(:Reference, 'this'), ms(:Reference, 'color'), []))
                                     ),
                                 )
                             )
      }
    end

    context 'inheritance' do
      ###
      # class A {}
      # class B extends A {}
      ###
      let(:ast) { %q{
        [
          {
            "nodeType": "Stmt_Class",
            "flags": 0,
            "extends": null,
            "implements": [],
            "name": {
              "nodeType": "Identifier",
              "name": "A"
            },
            "stmts": []
          },
          {
            "nodeType": "Stmt_Class",
            "flags": 0,
            "extends": {
              "nodeType": "Name",
              "parts": [
                "A"
              ]
            },
            "implements": [],
            "name": {
              "nodeType": "Identifier",
              "name": "B"
            },
            "stmts": []
          }
        ]
      } }

      it {
        expect(result).to eq sequence(
                                 ms(:Class, 'A', nil, ms(:None)),
                                 ms(:Class, 'B', 'A', ms(:None))
                             )
      }
    end
  end

  #   context 'module with self methods' do
  #     let(:code) { %q{
  #       module Pepita
  #         def self.canta!
  #           puts 'pri', 'pri'
  #         end
  #       end
  #     } }
  #     it { expect(result).to eq ms :Object, :Pepita, simple_method(:canta!, [],
  #                                                   simple_send(ms(:Self), :puts, [ms(:MuString, 'pri'), ms(:MuString, 'pri')])) }
  #
  #     it { check_valid result }
  #   end
  #
  #   context 'module with multiline self methods' do
  #     let(:code) { %q{
  #       module Pepita
  #         def self.vola!
  #           puts 'vuelo'
  #           puts 'luego existo'
  #         end
  #       end
  #     } }
  #     it { expect(result).to eq tag: :Object,
  #                               contents: [
  #                                 :Pepita,
  #                                 simple_method(:vola!, [], sequence(
  #                                     simple_send(ms(:Self), :puts, [{tag: :MuString, contents: 'vuelo'}]),
  #                                     simple_send(ms(:Self), :puts, [{tag: :MuString, contents: 'luego existo'}]))) ] }
  #     it { check_valid result }
  #   end
  #
  #   context 'module with methods with many arguments' do
  #     let(:code) { %q{
  #       module Pepita
  #         def self.come!(cantidad, *unidad)
  #         end
  #       end
  #     } }
  #     it { expect(result)
  #           .to eq ms(:Object,
  #                       :Pepita,
  #                       simple_method(
  #                         :come!,
  #                         [ms(:VariablePattern, :cantidad), ms(:VariablePattern, :unidad)],
  #                         ms(:MuNil))) }
  #     it { check_valid result }
  #   end
  #
  #   context 'constant assignment' do
  #     let(:code) { %q{Pepita = Object.new} }
  #     it { expect(result).to eq ms(:Assignment, :Pepita, simple_send(ms(:Reference, :Object), :new, [])) }
  #     it { check_valid result }
  #   end
  #
  #
  #   context 'simple class declarations' do
  #     let(:code) { %q{
  #       class Foo
  #       end
  #     } }
  #     it { expect(result).to eq ms(:Class, :Foo, nil, ms(:MuNil)) }
  #     it { check_valid result }
  #   end
  #
  #   context 'simple class declaration with inheritance' do
  #     let(:code) { %q{
  #       class Foo < Bar
  #       end
  #     } }
  #     it { expect(result).to eq ms(:Class, :Foo, :Bar, ms(:MuNil)) }
  #     it { check_valid result }
  #   end
  #
  #   context 'simple inline class with method' do
  #     let(:code) { %q{
  #       class Pepita; def canta; end; end
  #     } }
  #     it { expect(result).to eq ms(:Class, :Pepita, nil, simple_method(:canta, [], ms(:MuNil))) }
  #     it { check_valid result }
  #   end
  #
  #   context 'simple class with methods and parameters' do
  #     let(:code) { %q{
  #       class Pepita
  #         def canta!(cancion)
  #           puts cancion
  #         end
  #         def self.vola!(distancia)
  #         end
  #       end
  #     } }
  #     it { expect(result).to eq ms(:Class, :Pepita, nil,
  #                                 sequence(
  #                                   simple_method(:canta!, [ms(:VariablePattern, :cancion)], simple_send(ms(:Self), :puts, [ms(:Reference, :cancion)])),
  #                                   simple_method(:vola!, [ms(:VariablePattern, :distancia)], ms(:MuNil)))) }
  #     it { check_valid result }
  #   end
  #
  #   context 'unsupported features' do
  #     let(:code) { %q{
  #       class << self
  #       end
  #     } }
  #     it { expect(result).to eq ms :Other, "[s(:sclass,\n  s(:self), nil)]", nil }
  #     it { check_valid result }
  #   end
  #
  #   context 'rescue with no action' do
  #     let(:code) { %q{
  #       def foo
  #         bar
  #       rescue
  #       end
  #     } }
  #     it { check_valid result }
  #     it { expect(result).to eq try([ [ ms(:WildcardPattern),
  #                                       ms(:MuNil)] ],
  #                                   ms(:MuNil)) }
  #   end
  #
  #   context 'rescue with action' do
  #     let(:code) { %q{
  #       def foo
  #         bar
  #       rescue
  #         baz
  #       end
  #     } }
  #     it { check_valid result }
  #     it { expect(result).to eq try([ [ ms(:WildcardPattern),
  #                                       simple_send(ms(:Self), :baz, []) ] ],
  #                                   ms(:MuNil)) }
  #   end
  #
  #   context 'rescue with exception type' do
  #     let(:code) { %q{
  #       def foo
  #         bar
  #       rescue RuntimeError
  #         baz
  #       end
  #     } }
  #
  #     it { check_valid result }
  #     it { expect(result).to eq try([ [ ms(:TypePattern, :RuntimeError),
  #                                       simple_send(ms(:Self), :baz, []) ] ],
  #                                   ms(:MuNil) ) }
  #   end
  #
  #   context 'rescue with multiple exception types' do
  #     let(:code) { %q{
  #       def foo
  #         bar
  #       rescue RuntimeError, TypeError
  #         baz
  #       end
  #     } }
  #
  #     it { check_valid result }
  #     it { expect(result).to eq try([ [ ms(:UnionPattern, [
  #                                         ms(:TypePattern, :RuntimeError),
  #                                         ms(:TypePattern, :TypeError) ]),
  #                                       simple_send(ms(:Self), :baz, []) ] ],
  #                                   ms(:MuNil)) }
  #   end
  #
  #   context 'rescue with exception variable' do
  #     let(:code) { %q{
  #       def foo
  #         bar
  #       rescue => e
  #         baz
  #       end
  #     } }
  #
  #     it { check_valid result }
  #     it { expect(result).to eq try([ [ ms(:VariablePattern, :e),
  #                                       simple_send(ms(:Self), :baz, []) ] ],
  #                                   ms(:MuNil)) }
  #   end
  #
  #   context 'rescue exception with both type and variable' do
  #     let(:code) { %q{
  #       def foo
  #         bar
  #       rescue RuntimeError => e
  #         baz
  #       end
  #     } }
  #
  #     it { check_valid result }
  #     it { expect(result).to eq try([ [ ms(:AsPattern, :e, ms(:TypePattern, :RuntimeError)),
  #                                       simple_send(ms(:Self), :baz, []) ] ],
  #                                   ms(:MuNil)) }
  #   end
  #
  #   context 'rescue exception with multiple catches' do
  #     let(:code) { %q{
  #       def foo
  #         bar
  #       rescue RuntimeError => e
  #         baz
  #       rescue RangeError => e
  #         foobar
  #       end
  #     } }
  #
  #     it { check_valid result }
  #     it { expect(result).to eq try([ [ ms(:AsPattern, :e, ms(:TypePattern, :RuntimeError)),
  #                                       simple_send(ms(:Self), :baz, []) ],
  #                                     [ ms(:AsPattern, :e, ms(:TypePattern, :RangeError)),
  #                                       simple_send(ms(:Self), :foobar, []) ] ],
  #                                   ms(:MuNil)) }
  #   end
  #
  #   context 'rescue with begin keyword' do
  #     let(:code) { %q{
  #       def foo
  #         begin
  #           bar
  #         rescue
  #           baz
  #         end
  #       end
  #     } }
  #
  #     it { check_valid result }
  #     it { expect(result).to eq try([ [ ms(:WildcardPattern),
  #                                       simple_send(ms(:Self), :baz, []) ] ],
  #                                   ms(:MuNil)) }
  #   end
  #
  #   context 'rescue with ensure' do
  #     let(:code) { %q{
  #       def foo
  #         bar
  #       rescue
  #         baz
  #       ensure
  #         foobar
  #       end
  #     } }
  #
  #     it { check_valid result }
  #     it { expect(result).to eq try([ [ ms(:WildcardPattern),
  #                                       simple_send(ms(:Self), :baz, []) ] ],
  #                                   simple_send(ms(:Self), :foobar, [])) }
  #   end
end

