require 'bundler/setup'
require 'mulang/php'
require 'mulang'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def convert_php_to_mulang(ast)
  mulang_ast = Mulang::PHP.parse JSON.parse(ast, symbolize_names: true)
  check_valid mulang_ast
  mulang_ast
end

def check_valid(mulang_ast)
  out = Mulang::Code.new(Mulang::Language::External.new, mulang_ast).analyse smellsSet: { tag: "NoSmells" }, expectations: []
  expect(out['tag']).to eq 'AnalysisCompleted'
end
