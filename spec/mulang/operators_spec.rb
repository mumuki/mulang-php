require "spec_helper"

describe Mulang::PHP do
  include Mulang::PHP::Sexp

  describe '#parse' do
    let(:result) { convert_php_to_mulang ast }

    context 'operators' do
      context '==' do
        ###
        # "h" == "a";
        ###
        let(:ast) { %q{
          [
            {
              "nodeType": "Stmt_Expression",
              "expr": {
                "nodeType": "Expr_BinaryOp_Equal",
                "left": {
                  "nodeType": "Scalar_String",
                  "value": "h"
                },
                "right": {
                  "nodeType": "Scalar_String",
                  "value": "a"
                }
              }
            }
          ]
        } }

        it { expect(result).to eq ms :Application, primitive(:Equal), [ms(:MuString, 'h'), ms(:MuString, 'a')] }
      end

      context '!=' do
        ###
        # "h" != "a";
        ###
        let(:ast) { %q{
          [
            {
              "nodeType": "Stmt_Expression",
              "expr": {
                "nodeType": "Expr_BinaryOp_NotEqual",
                "left": {
                  "nodeType": "Scalar_String",
                  "value": "h"
                },
                "right": {
                  "nodeType": "Scalar_String",
                  "value": "a"
                }
              }
            }
          ]
        } }

        it { expect(result).to eq ms :Application, primitive(:NotEqual), [ms(:MuString, 'h'), ms(:MuString, 'a')] }
      end

      context '+' do
        ###
        # 2 + 3;
        ###
        let(:ast) { %q{
          [
            {
              "nodeType": "Stmt_Expression",
              "expr": {
                "nodeType": "Expr_BinaryOp_Plus",
                "left": {
                  "nodeType": "Scalar_LNumber",
                  "value": 2
                },
                "right": {
                  "nodeType": "Scalar_LNumber",
                  "value": 3
                }
              }
            }
          ]
        } }

        it {
          expect(result).to eq ms(
                                   :Application,
                                   ms(:Reference, '+'),
                                   [ms(:MuNumber, 2), ms(:MuNumber, 3)]
                               )
        }
      end

      context '.' do
        ###
        # "a"."b";
        ###
        let(:ast) { %q{
          [
            {
              "nodeType": "Stmt_Expression",
              "expr": {
                "nodeType": "Expr_BinaryOp_Concat",
                "left": {
                  "nodeType": "Scalar_String",
                  "value": "a"
                },
                "right": {
                  "nodeType": "Scalar_String",
                  "value": "b"
                }
              }
            }
          ]
        } }

        it {
          expect(result).to eq ms(
                                   :Application,
                                   ms(:Reference, '.'),
                                   [ms(:MuString, "a"), ms(:MuString, "b")]
                               )
        }
      end

      context '++' do
        ###
        # $a++;
        ###
        let(:ast) { %q{
          [
            {
              "nodeType": "Stmt_Expression",
              "expr": {
                "nodeType": "Expr_PostInc",
                "var": {
                  "nodeType": "Expr_Variable",
                  "name": "a"
                }
              }
            }
          ]
        } }

        it {
          expect(result).to eq ms(
                                   :Application,
                                   ms(:Reference, '+'),
                                   [ms(:Reference, 'a'), ms(:MuNumber, 1)]
                               )
        }
      end

      context '+=' do
        ###
        # $a += 8;
        ###
        let(:ast) { %q{
          [
            {
              "nodeType": "Stmt_Expression",
              "expr": {
                "nodeType": "Expr_AssignOp_Plus",
                "var": {
                  "nodeType": "Expr_Variable",
                  "name": "a"
                },
                "expr": {
                  "nodeType": "Scalar_LNumber",
                  "value": 8
                }
              }
            }
          ]
        } }

        it {
          expect(result).to eq ms(
                                   :Application,
                                   ms(:Reference, '+='),
                                   [ms(:Reference, 'a'), ms(:MuNumber, 8)]
                               )
        }
      end

      context 'lots of mixed operators' do
        ###
        # ((2 && true || false > 3 === 3) <= 2 ** 8 / 8 % 1 | "j") !== 2 and 9;
        ###
        let(:ast) { %q{
          [{"nodeType":"Stmt_Expression","expr":{"nodeType":"Expr_BinaryOp_LogicalAnd","left":{"nodeType":"Expr_BinaryOp_NotIdentical","left":{"nodeType":"Expr_BinaryOp_BitwiseOr","left":{"nodeType":"Expr_BinaryOp_SmallerOrEqual","left":{"nodeType":"Expr_BinaryOp_BooleanOr","left":{"nodeType":"Expr_BinaryOp_BooleanAnd","left":{"nodeType":"Scalar_LNumber","value":2},"right":{"nodeType":"Expr_ConstFetch","name":{"nodeType":"Name","parts":["true"]}}},"right":{"nodeType":"Expr_BinaryOp_Identical","left":{"nodeType":"Expr_BinaryOp_Greater","left":{"nodeType":"Expr_ConstFetch","name":{"nodeType":"Name","parts":["false"]}},"right":{"nodeType":"Scalar_LNumber","value":3}},"right":{"nodeType":"Scalar_LNumber","value":3}}},"right":{"nodeType":"Expr_BinaryOp_Mod","left":{"nodeType":"Expr_BinaryOp_Div","left":{"nodeType":"Expr_BinaryOp_Pow","left":{"nodeType":"Scalar_LNumber","value":2},"right":{"nodeType":"Scalar_LNumber","value":8}},"right":{"nodeType":"Scalar_LNumber","value":8}},"right":{"nodeType":"Scalar_LNumber","value":1}}},"right":{"nodeType":"Scalar_String","value":"j"}},"right":{"nodeType":"Scalar_LNumber","value":2}},"right":{"nodeType":"Scalar_LNumber","value":9}}}]
        } }

        it { expect(result).to eq({:tag=>:Application, :contents=>[{:tag=>:Reference, :contents=>"and"}, [{:tag=>:Application, :contents=>[{:tag=>:Reference, :contents=>"!=="}, [{:tag=>:Application, :contents=>[{:tag=>:Reference, :contents=>"|"}, [{:tag=>:Application, :contents=>[{:tag=>:Reference, :contents=>"<="}, [{:tag=>:Application, :contents=>[{:tag=>:Reference, :contents=>"||"}, [{:tag=>:Application, :contents=>[{:tag=>:Reference, :contents=>"&&"}, [{:tag=>:MuNumber, :contents=>2}, {:tag=>:MuBool, :contents=>true}]]}, {:tag=>:Application, :contents=>[{:tag=>:Reference, :contents=>"==="}, [{:tag=>:Application, :contents=>[{:tag=>:Reference, :contents=>">"}, [{:tag=>:MuBool, :contents=>false}, {:tag=>:MuNumber, :contents=>3}]]}, {:tag=>:MuNumber, :contents=>3}]]}]]}, {:tag=>:Application, :contents=>[{:tag=>:Reference, :contents=>"%"}, [{:tag=>:Application, :contents=>[{:tag=>:Reference, :contents=>"/"}, [{:tag=>:Application, :contents=>[{:tag=>:Reference, :contents=>"**"}, [{:tag=>:MuNumber, :contents=>2}, {:tag=>:MuNumber, :contents=>8}]]}, {:tag=>:MuNumber, :contents=>8}]]}, {:tag=>:MuNumber, :contents=>1}]]}]]}, {:tag=>:MuString, :contents=>"j"}]]}, {:tag=>:MuNumber, :contents=>2}]]}, {:tag=>:MuNumber, :contents=>9}]]}) }
      end
    end
  end
end
