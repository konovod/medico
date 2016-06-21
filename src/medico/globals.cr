require "./data/i18n/ru.cr"

alias FLOAT = Float32


def f(value) : FLOAT
  return FLOAT.new(value)
end

def s(value)
  return $s[value]
end

class TEST_RND
  include Random

  def next_u32
    raise "RANDOM NOT PASSED"
  end
  def initialize

  end

end


DEF_RND = TEST_RND.new  #Random::DEFAULT

# TODO: def fill_hash
