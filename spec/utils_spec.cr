require "spec"
require "../src/medico/globals.cr"


$r = Random.new(1)

it "weighted_sample" do
  weighted_sample([1,100,3,4,5,6,7], $r){|i| i}.should eq(100)
  weighted_sample([-1,-100,-3,4,5,6,7], $r, &.abs).should eq(-100)
end
