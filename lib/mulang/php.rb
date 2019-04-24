require 'ast'
require 'mumukit/core'

require_relative "./php/version"

module Mulang
  module PHP
    def self.parse(php_ast)
      Mulang::PHP::AstProcessor.new.process_block php_ast
    end

    def self.language
      Mulang::Language::External.new { |it| parse(it) }
    end
  end
end

require_relative "./php/sexp"
require_relative './php/ast_processor'
