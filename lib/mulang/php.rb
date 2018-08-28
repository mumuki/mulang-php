require 'ast'
require 'parser/current'
require 'mumukit/core'

require_relative "./php/version"

module Mulang
  module PHP
    def self.parse(php_code)
      Mulang::PHP::AstProcessor.new.process Mulang::PHP::SexpParser.parser(php_code)
    end

    def self.language
      Mumukit::Language::External.new { |it| parse(it) }
    end
  end
end

require_relative "./php/sexp"
require_relative './php/sexp_parser'
require_relative './php/ast_processor'
