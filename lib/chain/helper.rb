class Hash
  def to_s_of_method_chaining
    self.inject('') { |result, (key, value)|
      result += ".#{key}(#{value.is_a?(Symbol) ? ":#{value}" : value})"
    }[1..-1]
  end
end
