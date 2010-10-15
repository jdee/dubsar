class String
  def upcase?
    upcase == self
  end

  def capitalized?
    slice(0,1).upcase?
  end
end
