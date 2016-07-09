require "./spec_helper"
require "../src/medico/grammar.cr"

include Grammar

describe Grammar do
  it "nouns" do
    n = Noun.new(parse: "Wtest{1,2,3,4,5,6,~,1n,2n,3n,4n,5n,6n,~}")
    n.gender.should eq Gender::She
    n.to_s.should eq "test1"
    n.to_s(Case::Dative).should eq "test3"
    n.to_s(Case::Locative, Number::Plural).should eq "test~"

    n = Noun.new(Gender::They, "money")
    n.to_s(Case::Accusative, Number::Plural).should eq "money"
  end


end
