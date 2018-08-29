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

        it { expect(result).to eq ms :None }
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
        context 'more than one element' do
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
      end
    end

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

      it { expect(result).to eq ms :Assignment, 'some_var', ms(:MuNumber, 2 )}
    end

    # context 'simple module' do
    #   let(:code) { %q{
    #     module Pepita
    #     end
    #   } }
    #   it { expect(result).to eq ms :Object, :Pepita, ms(:MuNil) }
    #   it { check_valid result }
    # end
    #
    # context 'modules and variables' do
    #   let(:code) { %q{
    #     module Pepita
    #     end
    #     module Pepona
    #     end
    #     otra_pepita = Pepita
    #     otra_pepona = Pepona
    #   } }
    #   it { expect(result[:tag]).to eq :Sequence }
    #   it { expect(result[:contents].length).to eq 4 }
    # end

    # context 'variables' do
    #   ###
    #   # $one = $another;
    #   ###
    #   let(:ast) { %q{
    #     [
    #         {
    #             "nodeType": "Stmt_Expression",
    #             "expr": {
    #                 "nodeType": "Expr_Assign",
    #                 "var": {
    #                     "nodeType": "Expr_Variable",
    #                     "name": "otra_pepita"
    #                 },
    #                 "expr": {
    #                     "nodeType": "Expr_Variable",
    #                     "name": "pepita"
    #                 }
    #             }
    #         }
    #     ]
    #   } }
    #
    #   it { expect(result).to eq ms :Assignment, :otra_pepita, ms(:Reference, :pepita )}
    #   it { check_valid result }
    # end

  #   context 'instance variables references' do
  #     let(:code) { %q{@nigiri} }
  #     it { expect(result).to eq ms :Reference, :@nigiri }
  #     it { check_valid result }
  #   end
  #
  #   context 'instance variables assignment' do
  #     let(:code) { %q{@wasabi = true} }
  #     it { expect(result).to eq ms :Assignment, :@wasabi, ms(:MuBool, true) }
  #     it { check_valid result }
  #   end
  #
  #   context 'returns' do
  #     let(:code) { %q{return 9} }
  #     it { expect(result).to eq ms(:Return, ms(:MuNumber, 9)) }
  #     it { check_valid result }
  #   end
  #
  #   context 'or boolean expressions' do
  #     let(:code) { %q{true || true} }
  #     it { expect(result).to eq simple_send(ms(:MuBool, true), '||', [ms(:MuBool, true)]) }
  #     it { check_valid result }
  #   end
  #
  #   context '&& boolean expressions' do
  #     let(:code) { %q{true && true} }
  #     it { expect(result).to eq simple_send(ms(:MuBool, true), '&&', [ms(:MuBool, true)]) }
  #   end
  #
  #   context '|| boolean expressions' do
  #     let(:code) { %q{true or true} }
  #     it { expect(result).to eq simple_send(ms(:MuBool, true), '||', [ms(:MuBool, true)]) }
  #   end
  #
  #   context 'ints' do
  #     let(:code) { %q{60} }
  #     it { expect(result).to eq ms(:MuNumber, 60) }
  #   end
  #
  #   context 'symbols' do
  #     let(:code) { %q{:foo} }
  #     it { expect(result).to eq ms(:MuSymbol, 'foo') }
  #     it { check_valid result }
  #   end
  #
  #   context 'interpolations' do
  #     let(:code) { %q{"foo #{@bar} - #{@baz}"} }
  #     it { expect(result).to eq simple_send(ms(:MuList,
  #                                   ms(:MuString, "foo "),
  #                                   ms(:Reference, :@bar),
  #                                   ms(:MuString, " - "),
  #                                   ms(:Reference, :@baz)), :join, []) }
  #     it { check_valid result }
  #   end
  #
  #   context 'regexps' do
  #     let(:code) { %q{/foo.*/} }
  #     it { expect(result).to eq simple_send(ms(:Reference, :Regexp), :new, [ms(:MuString, 'foo.*')]) }
  #     it { check_valid result }
  #   end
  #
  #   context 'doubles' do
  #     let(:code) { %q{60.4} }
  #     it { expect(result).to eq ms(:MuNumber, 60.4) }
  #     it { check_valid result }
  #   end
  #
  #   context 'implicit sends' do
  #     let(:code) { %q{m 5} }
  #     it { expect(result).to eq ms :Send, ms(:Self), ms(:Reference, :m), [ms(:MuNumber, 5)] }
  #     it { check_valid result }
  #   end
  #
  #   context 'math expressions' do
  #     let(:code) { %q{4 + 5} }
  #     it { expect(result).to eq ms :Send, ms(:MuNumber, 4), ms(:Reference, :+), [ms(:MuNumber, 5)] }
  #     it { check_valid result }
  #   end
  #
  #   context 'equal comparisons' do
  #     let(:code) { %q{ 4 == 3 } }
  #     it { expect(result).to eq ms :Send, ms(:MuNumber, 4), {tag: :Equal}, [ms(:MuNumber, 3)] }
  #     it { check_valid result }
  #   end
  #
  #   context 'not equal comparisons' do
  #     let(:code) { %q{ 4 != 3 } }
  #     it { expect(result).to eq ms :Send, ms(:MuNumber, 4), {tag: :NotEqual}, [ms(:MuNumber, 3)] }
  #     it { check_valid result }
  #   end
  #
  #   context 'true' do
  #     let(:code) { %q{true} }
  #     it { expect(result).to eq ms :MuBool, true }
  #     it { check_valid result }
  #   end
  #
  #   context 'false' do
  #     let(:code) { %q{false} }
  #     it { expect(result).to eq ms :MuBool, false }
  #     it { check_valid result }
  #   end
  #
  #    context 'nil' do
  #     let(:code) { %q{nil} }
  #     it { expect(result).to eq ms :MuNil }
  #     it { check_valid result }
  #   end
  #
  #   context 'lists' do
  #     let(:code) { %q{[4, 5]} }
  #     it { expect(result).to eq ms :MuList,  ms(:MuNumber, 4), ms(:MuNumber, 5) }
  #     it { check_valid result }
  #   end
  #
  #   context 'empty lists' do
  #     let(:code) { %q{[]} }
  #     it { expect(result).to eq tag: :MuList, contents: [] }
  #     it { check_valid result }
  #   end
  #
  #   describe 'lambdas' do
  #     let(:list) { ms :MuList,  ms(:MuNumber, 4), ms(:MuNumber, 5) }
  #     context 'map' do
  #       let(:code) { %q{[4, 5].map { |x| x + 1 }} }
  #       it { expect(result).to eq simple_send list, :map, [
  #                                   ms(:Lambda,
  #                                     [ms(:VariablePattern, :x)],
  #                                     simple_send(ms(:Reference, :x), :+, [ms(:MuNumber, 1)]))] }
  #       it { check_valid result }
  #     end
  #
  #     context 'inject' do
  #       let(:code) { %q{[4, 5].inject(0) { |x, y| x + y }} }
  #       it { expect(result).to eq simple_send list, :inject, [
  #                                   ms(:MuNumber, 0),
  #                                   ms(:Lambda,
  #                                     [ms(:VariablePattern, :x), ms(:VariablePattern, :y)],
  #                                     simple_send(ms(:Reference, :x), :+, [ms(:Reference, :y)]))] }
  #       it { check_valid result }
  #     end
  #   end
  #
  #   context 'message sends' do
  #     let(:code) { %q{
  #       a = 2
  #       a + 6
  #     } }
  #     it { expect(result[:contents][1]).to eq simple_send(ms(:Reference, :a), :+, [ms(:MuNumber, 6)]) }
  #     it { check_valid result }
  #   end
  #
  #   context 'modules and variables' do
  #     let(:code) { %q{
  #       module Pepita
  #       end
  #       module Pepona
  #       end
  #       otra_pepita = Pepita
  #       otra_pepona = Pepona
  #     } }
  #     it { expect(result[:tag]).to eq :Sequence }
  #     it { check_valid result }
  #   end
  #
  #   context 'module with module' do
  #     let(:code) { %q{
  #       module Pepita
  #         def self.canta
  #         end
  #       end
  #     } }
  #     it { expect(result).to eq ms(:Object, :Pepita, simple_method(:canta, [], ms(:MuNil))) }
  #     it { check_valid result }
  #   end
  #
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
  #
  #   context 'module with if-else' do
  #     let(:code) { %q{
  #       module Pepita
  #         def self.decidi!
  #           if esta_bien?
  #             hacelo!
  #           else
  #             no_lo_hagas!
  #           end
  #         end
  #       end
  #     } }
  #     it { expect(result).to eq tag: :Object,
  #                               contents: [
  #                                 :Pepita,
  #                                 simple_method(
  #                                   :decidi!,
  #                                   [],
  #                                   { tag: :If,
  #                                     contents: [
  #                                       simple_send(
  #                                         ms(:Self),
  #                                         :esta_bien?,
  #                                         []),
  #                                       simple_send(
  #                                         ms(:Self),
  #                                         :hacelo!,
  #                                         []),
  #                                       simple_send(
  #                                         ms(:Self),
  #                                         :no_lo_hagas!,
  #                                         [])
  #                                     ]})
  #                               ]}
  #     it { check_valid result }
  #   end
  #
  #   context 'module with if' do
  #     let(:code) { %q{
  #       module Pepita
  #         def self.decidi!
  #           if esta_bien?
  #             hacelo!
  #           end
  #         end
  #       end
  #     } }
  #     it { expect(result).to eq ms(:Object,
  #                                 :Pepita,
  #                                 simple_method(:decidi!, [],
  #                                   ms(:If,
  #                                     simple_send(ms(:Self), :esta_bien?, []),
  #                                     simple_send(ms(:Self), :hacelo!, []),
  #                                     ms(:MuNil)))) }
  #     it { check_valid result }
  #   end
  #
  #   context 'module with unless' do
  #     let(:code) { %q{
  #       module Pepita
  #         def self.decidi!
  #           unless esta_bien?
  #             hacelo!
  #           end
  #         end
  #       end
  #     } }
  #     it { expect(result).to eq ms(:Object,
  #                                 :Pepita,
  #                                 simple_method(:decidi!, [],
  #                                   ms(:If,
  #                                     simple_send(ms(:Self), :esta_bien?, []),
  #                                     ms(:MuNil),
  #                                     simple_send(ms(:Self),:hacelo!, [])))) }
  #     it { check_valid result }
  #   end
  #
  #   context 'module with suffix unless' do
  #     let(:code) { %q{
  #       module Pepita
  #         def self.decidi!
  #           hacelo! unless esta_bien?
  #         end
  #       end
  #     } }
  #     it { expect(result).to eq ms(:Object,
  #                                 :Pepita,
  #                                 simple_method(:decidi!, [],
  #                                   ms(:If,
  #                                     simple_send(ms(:Self), :esta_bien?, []),
  #                                     ms(:MuNil),
  #                                     simple_send(ms(:Self), :hacelo!, [])))) }
  #   end
  #
  #   context 'simple class declararions' do
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
  #   context 'mixins' do
  #     let(:code) { %q{
  #       class Foo
  #         include Bar
  #       end
  #     } }
  #     it { expect(result).to eq ms :Class, :Foo, nil, simple_send(ms(:Self), :include, [ms(:Reference, :Bar)]) }
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
  #   context 'hashes' do
  #     let(:code) { %q{{foo:3}} }
  #     it { expect(result).to eq ms :Other, "[s(:hash,\n  s(:pair,\n    s(:sym, :foo),\n    s(:int, 3)))]", nil }
  #     it { check_valid result }
  #   end
  #
  #   context 'creation' do
  #     let(:code) { %q{Object.new} }
  #     it { expect(result).to eq simple_send(ms(:Reference, :Object), :new, []) }
  #     it { check_valid result }
  #   end
  #
  #   context 'ranges' do
  #     let(:code) { %q{1..1024} }
  #     it { expect(result).to eq ms :Other, "(irange\n  (int 1)\n  (int 1024))", nil }
  #     it { check_valid result }
  #   end
  #
  #   context 'ranges with parenthesis and blocks' do
  #     let(:code) { %q{l = (1..1024*1024*10).map { Object.new }} }
  #     it { check_valid result }
  #   end
  #
  #   context 'hash def' do
  #     let(:code) { %q{def hash;end} }
  #     it { expect(result).to eq mu_method :HashMethod, [], ms(:MuNil) }
  #   end
  #
  #   context 'equal? def' do
  #     let(:code) { %q{def equal?;end} }
  #     it { expect(result).to eq mu_method :EqualMethod, [], ms(:MuNil) }
  #   end
  #
  #   context 'eql? def' do
  #     let(:code) { %q{def equal?;end} }
  #     it { expect(result).to eq mu_method :EqualMethod, [], ms(:MuNil) }
  #   end
  #
  #   context '== def' do
  #     let(:code) { %q{def equal?;end} }
  #     it { expect(result).to eq mu_method :EqualMethod, [], ms(:MuNil) }
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
  #
  #   context 'op assignment -' do
  #     let(:code) { 'a -= 3' }
  #
  #     it { check_valid result }
  #     it { expect(result).to eq(Mulang::PHP.parse 'a = a - 3')}
  #   end
  #
  #   context 'op assignment on local array var' do
  #     let(:code) { 'a[1] += 3' }
  #
  #     it { check_valid result }
  #     it { expect(result).to eq(Mulang::PHP.parse('a[1] = a[1] + 3'))}
  #   end
  #
  #   context 'op assignment on instance array var' do
  #     let(:code) { '@a[1] *= 3' }
  #
  #     it { check_valid result }
  #     it { expect(result).to eq(Mulang::PHP.parse('@a[1] = @a[1] * 3'))}
  #   end
  #
  #   context 'op assignment on local var with attribute accessor' do
  #     let(:code) { 'a.b /= 3' }
  #
  #     it { check_valid result }
  #     it { expect(result).to eq(Mulang::PHP.parse('a.b = a.b / 3'))}
  #   end
  #
  #   context 'op assignment on instance var with attribute accessor' do
  #     let(:code) { '@a.b ||= false' }
  #
  #     it { check_valid result }
  #     it { expect(result).to eq(Mulang::PHP.parse('@a.b = @a.b || false'))}
  #   end
  #
  #   context 'and assignment' do
  #     let(:code) { 'a &&= false' }
  #
  #     it { check_valid result }
  #     it { expect(result).to eq(Mulang::PHP.parse('a = a && false'))}
  #   end
  end
end

