require "spec_helper"

describe Mulang::PHP do
  include Mulang::PHP::Sexp

  describe '#parse' do
    let(:result) { convert_php_to_mulang ast }

    context 'statements' do
      context 'assignment' do
        ###
        # $some_var = 2;
        ###
        let(:ast) { %q{
          [
            {
              "nodeType": "Stmt_Expression",
              "expr": {
                "nodeType": "Expr_Assign",
                "var": {
                  "nodeType": "Expr_Variable",
                  "name": "some_var"
                },
                "expr": {
                  "nodeType": "Scalar_LNumber",
                  "value": 2
                }
              }
            }
          ]
        } }

        it { expect(result).to eq ms :Assignment, 'some_var', ms(:MuNumber, 2) }
      end

      context 'print' do
        ###
        # echo "helolwrorlddd";
        ###
        let(:ast) { %q{
          [
            {
              "nodeType": "Stmt_Echo",
              "exprs": [
                {
                  "nodeType": "Scalar_String",
                  "value": "helolwrorlddd"
                }
              ]
            }
          ]
        } }

        it { expect(result).to eq ms :Print, ms(:MuString, 'helolwrorlddd') }
      end

      context 'if' do
        ###
        # if (2 == 3) { echo "Oh no!"; echo "Math is broken!"; }
        ###
        let(:ast) { %q{
          [
            {
              "nodeType": "Stmt_If",
              "cond": {
                "nodeType": "Expr_BinaryOp_Equal",
                "left": {
                  "nodeType": "Scalar_LNumber",
                  "value": 2
                },
                "right": {
                  "nodeType": "Scalar_LNumber",
                  "value": 3
                }
              },
              "stmts": [
                {
                  "nodeType": "Stmt_Echo",
                  "exprs": [
                    {
                      "nodeType": "Scalar_String",
                      "value": "Oh no!"
                    }
                  ]
                },
                {
                  "nodeType": "Stmt_Echo",
                  "exprs": [
                    {
                      "nodeType": "Scalar_String",
                      "value": "Math is broken!"
                    }
                  ]
                }
              ],
              "elseifs": [],
              "else": null
            }
          ]
        } }

        it {
          expect(result).to eq ms(
                                   :If,
                                   ms(:Application, primitive(:Equal), [ms(:MuNumber, 2), ms(:MuNumber, 3)]),
                                   sequence(
                                       ms(:Print, ms(:MuString, 'Oh no!')),
                                       ms(:Print, ms(:MuString, 'Math is broken!')),
                                   ),
                                   ms(:None)
                               )
        }
      end

      context 'if - else' do
        ###
        # if (true) { echo "asd"; } else { echo "qwe"; }
        ###
        let(:ast) { %q{
          [
            {
              "nodeType": "Stmt_If",
              "cond": {
                "nodeType": "Expr_ConstFetch",
                "name": {
                  "nodeType": "Name",
                  "parts": [
                    "true"
                  ]
                }
              },
              "stmts": [
                {
                  "nodeType": "Stmt_Echo",
                  "exprs": [
                    {
                      "nodeType": "Scalar_String",
                      "value": "asd"
                    }
                  ]
                }
              ],
              "elseifs": [],
              "else": {
                "nodeType": "Stmt_Else",
                "stmts": [
                  {
                    "nodeType": "Stmt_Echo",
                    "exprs": [
                      {
                        "nodeType": "Scalar_String",
                        "value": "qwe"
                      }
                    ]
                  }
                ]
              }
            }
          ]
        } }

        it {
          expect(result).to eq ms(
                                   :If,
                                   ms(:MuBool, true),
                                   ms(:Print, ms(:MuString, 'asd')),
                                   ms(:Print, ms(:MuString, 'qwe'))
                               )
        }
      end

      context 'if - elseif - else' do
        ###
        # if (false) { 1; } else if (true) { 2; } else { 3; }
        ###
        let(:ast) { %q{
          [
            {
              "nodeType": "Stmt_If",
              "cond": {
                "nodeType": "Expr_ConstFetch",
                "name": {
                  "nodeType": "Name",
                  "parts": [
                    "false"
                  ]
                }
              },
              "stmts": [
                {
                  "nodeType": "Stmt_Expression",
                  "expr": {
                    "nodeType": "Scalar_LNumber",
                    "value": 1
                  }
                }
              ],
              "elseifs": [],
              "else": {
                "nodeType": "Stmt_Else",
                "stmts": [
                  {
                    "nodeType": "Stmt_If",
                    "cond": {
                      "nodeType": "Expr_ConstFetch",
                      "name": {
                        "nodeType": "Name",
                        "parts": [
                          "true"
                        ]
                      }
                    },
                    "stmts": [
                      {
                        "nodeType": "Stmt_Expression",
                        "expr": {
                          "nodeType": "Scalar_LNumber",
                          "value": 2
                        }
                      }
                    ],
                    "elseifs": [],
                    "else": {
                      "nodeType": "Stmt_Else",
                      "stmts": [
                        {
                          "nodeType": "Stmt_Expression",
                          "expr": {
                            "nodeType": "Scalar_LNumber",
                            "value": 3
                          }
                        }
                      ]
                    }
                  }
                ]
              }
            }
          ]
        } }

        it {
          expect(result).to eq ms(
                                   :If,
                                   ms(:MuBool, false),
                                   ms(:MuNumber, 1),
                                   ms(
                                       :If,
                                       ms(:MuBool, true),
                                       ms(:MuNumber, 2),
                                       ms(:MuNumber, 3)
                                   )
                               )
        }
      end

      context 'for' do
        ###
        # for ($i = 1; $i <= 10; $i++) { echo $i; }
        ###
        let(:ast) { %q{
          [
            {
              "nodeType": "Stmt_For",
              "init": [
                {
                  "nodeType": "Expr_Assign",
                  "var": {
                    "nodeType": "Expr_Variable",
                    "name": "i"
                  },
                  "expr": {
                    "nodeType": "Scalar_LNumber",
                    "value": 1
                  }
                }
              ],
              "cond": [
                {
                  "nodeType": "Expr_BinaryOp_SmallerOrEqual",
                  "left": {
                    "nodeType": "Expr_Variable",
                    "name": "i"
                  },
                  "right": {
                    "nodeType": "Scalar_LNumber",
                    "value": 10
                  }
                }
              ],
              "loop": [
                {
                  "nodeType": "Expr_PostInc",
                  "var": {
                    "nodeType": "Expr_Variable",
                    "name": "i"
                  }
                }
              ],
              "stmts": [
                {
                  "nodeType": "Stmt_Echo",
                  "exprs": [
                    {
                      "nodeType": "Expr_Variable",
                      "name": "i"
                    }
                  ]
                }
              ]
            }
          ]
        } }

        it {
          expect(result).to eq ms(
                                   :ForLoop,
                                   ms(:Assignment, 'i', ms(:MuNumber, 1)),
                                   ms(:Application, ms(:Reference, '<='), [ms(:Reference, 'i'), ms(:MuNumber, 10)]),
                                   ms(:Application, ms(:Reference, '+'), [ms(:Reference, 'i'), ms(:MuNumber, 1)]),
                                   ms(:Print, ms(:Reference, 'i'))
                               )
        }
      end

      context 'while' do
        ###
        # while (true) { echo "infinito"; }
        ###
        let(:ast) { %q{
          [
            {
              "nodeType": "Stmt_While",
              "cond": {
                "nodeType": "Expr_ConstFetch",
                "name": {
                  "nodeType": "Name",
                  "parts": [
                    "true"
                  ]
                }
              },
              "stmts": [
                {
                  "nodeType": "Stmt_Echo",
                  "exprs": [
                    {
                      "nodeType": "Scalar_String",
                      "value": "infinito"
                    }
                  ]
                }
              ]
            }
          ]
        } }

        it {
          expect(result).to eq ms(
                                   :While,
                                   ms(:MuBool, true),
                                   ms(:Print, ms(:MuString, 'infinito'))
                               )
        }
      end

      context 'foreach' do
        ###
        # $a = [1, 2] ; foreach ($a as $v) { echo $v; }
        ###
        let(:ast) { %q{
          [
            {
              "nodeType": "Stmt_Expression",
              "expr": {
                "nodeType": "Expr_Assign",
                "var": {
                  "nodeType": "Expr_Variable",
                  "name": "a"
                },
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
                        "nodeType": "Scalar_LNumber",
                        "value": 2
                      },
                      "byRef": false
                    }
                  ]
                }
              }
            },
            {
              "nodeType": "Stmt_Foreach",
              "expr": {
                "nodeType": "Expr_Variable",
                "name": "a"
              },
              "keyVar": null,
              "byRef": false,
              "valueVar": {
                "nodeType": "Expr_Variable",
                "name": "v"
              },
              "stmts": [
                {
                  "nodeType": "Stmt_Echo",
                  "exprs": [
                    {
                      "nodeType": "Expr_Variable",
                      "name": "v"
                    }
                  ]
                }
              ]
            }
          ]
        } }

        it {
          expect(result).to eq sequence(
                                   ms(:Assignment, 'a', ms(:MuList, [ms(:MuNumber, 1), ms(:MuNumber, 2)])),
                                   ms(
                                     :For,
                                     [
                                         ms(:Generator, ms(:VariablePattern, 'v'), ms(:Reference, 'a'))
                                     ],
                                     ms(:Print, ms(:Reference, 'v'))
                                   )
                               )
        }
      end
    end
  end
end