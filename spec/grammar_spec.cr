require "./spec_helper"
require "../src/medico/game/grammar.cr"

include Grammar

describe Grammar do
  it "nouns" do
    n = Noun.new(parse: "Wtest{1,2,3,4,5,6,~,1n,2n,3n,4n,5n,6n,~}")
    n.gender.should eq Gender::She
    n.get.should eq "test1"
    n.get(Case::Dative).should eq "test3"
    n.get(Case::Locative, Number::Plural).should eq "test~"

    n = Noun.new(Gender::They, "money")
    n.get(Case::Accusative, Number::Plural).should eq "money"
  end

  it "adjectives" do
    n = Noun.new(parse: "M{человек,человека,человеку,человека,человеком,человеке,человеке,люди,людей,людям,людей,людьми,людях,людях}")
    adj = Adjective.new(parse: "Черн{ый,ого,ому,ого,ым,ом,ом,ая,ой,ой,ую,ой,ой,ой,ое,ого,ому,ое,ым,ом,ом,ые,ых,ым,ых,ыми,ых,ых}")
    adj.get(Gender::It, Case::Locative).should eq "Черном"
    (adj + n).get(Case::Accusative, Number::Single).should eq "Черного человека"
  end

  it "parse multiple" do
    n = Noun.new(parse: "Wtest{1,2,3,4,5,6,~,1n,2n,3n,4n,5n,6n,~} or not test{x1,x2,x3,x4,x5,x6,x~,x1n,x2n,x3n,x4n,x5n,x6n,x~}")
    n.gender.should eq Gender::She
    n.get.should eq "test1 or not testx1"
    n.get(Case::Dative).should eq "test3 or not testx3"
    n.get(Case::Locative, Number::Plural).should eq "test~ or not testx~"
  end
end
