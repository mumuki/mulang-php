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
  end

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

  #   context 'message sends' do
  #     let(:code) { %q{
  #       a = 2
  #       a + 6
  #     } }
  #     it { expect(result[:contents][1]).to eq simple_send(ms(:Reference, :a), :+, [ms(:MuNumber, 6)]) }
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

