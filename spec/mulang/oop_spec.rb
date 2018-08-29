require "spec_helper"

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

    context 'extends' do
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

    context 'extends & implements' do
      ###
      # class A extends B implements C, D { }
      ###
      let(:ast) { %q{
        [
          {
            "nodeType": "Stmt_Class",
            "flags": 0,
            "extends": {
              "nodeType": "Name",
              "parts": [
                "B"
              ]
            },
            "implements": [
              {
                "nodeType": "Name",
                "parts": [
                  "C"
                ]
              },
              {
                "nodeType": "Name",
                "parts": [
                  "D"
                ]
              }
            ],
            "name": {
              "nodeType": "Identifier",
              "name": "A"
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
                      "name": "hello"
                    },
                    "default": {
                      "nodeType": "Scalar_LNumber",
                      "value": 2
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
                                 'A',
                                 'B',
                                 sequence(
                                   ms(:Implement, ms(:Reference, 'C')),
                                   ms(:Implement, ms(:Reference, 'D')),
                                   ms(:Attribute, 'hello', ms(:MuNumber, 2))
                                 )
                             )
      }
    end

    context 'interface' do
      ###
      # interface A extends C, D { public function getHtml($template); }
      ###
      let(:ast) { %q{
        [
          {
            "nodeType": "Stmt_Interface",
            "extends": [
              {
                "nodeType": "Name",
                "parts": [
                  "C"
                ]
              },
              {
                "nodeType": "Name",
                "parts": [
                  "D"
                ]
              }
            ],
            "name": {
              "nodeType": "Identifier",
              "name": "A"
            },
            "stmts": [
              {
                "nodeType": "Stmt_ClassMethod",
                "flags": 1,
                "byRef": false,
                "name": {
                  "nodeType": "Identifier",
                  "name": "getHtml"
                },
                "params": [
                  {
                    "nodeType": "Param",
                    "type": null,
                    "byRef": false,
                    "variadic": false,
                    "var": {
                      "nodeType": "Expr_Variable",
                      "name": "template"
                    },
                    "default": null
                  }
                ],
                "returnType": null,
                "stmts": null
              }
            ]
          }
        ]
      } }

      xit { # // TODO: It isn't working. Check
        expect(result).to eq '...'
      }
    end
  end
end

