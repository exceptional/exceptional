class Regexp
  def to_json(options = {})
    "\"#{self.to_s}\""
  end
end
class Fixnum
  def to_json(options = {})
    to_s
  end
end
