require "spec_helper"

describe Mulang::PHP do
  include Mulang::PHP::Sexp

  describe '#parse' do
    let(:result) { convert_php_to_mulang ast }

    context 'unsupported things' do
      ###
      # "hola {$variable}!!";
      ###
      let(:ast) { %q{
        [
          {
            "nodeType": "Stmt_Expression",
            "expr": {
              "nodeType": "Scalar_Encapsed",
              "parts": [
                {
                  "nodeType": "Scalar_EncapsedStringPart",
                  "value": "hola "
                },
                {
                  "nodeType": "Expr_Variable",
                  "name": "variable"
                },
                {
                  "nodeType": "Scalar_EncapsedStringPart",
                  "value": "!!"
                }
              ]
            }
          }
        ]
        } }

      it { expect(result[:tag]).to eq :Other }
      it { expect(result[:contents][0]).to include 'on_Scalar_Encapsed' }
    end
  end
end
