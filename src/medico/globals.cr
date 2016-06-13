require "./data/i18n/ru.cr"

alias FLOAT = Float32

def f(value) : FLOAT
  return FLOAT.new(value)
end

def s(value)
  return $s[value.to_s]
end
