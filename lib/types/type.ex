defprotocol XDR.Type do
  def resolve_type(type, custom_types)
  def resolve_type!(type, custom_types)
  def build_value(type, value)
  def build_value!(type, value)
  # def encode(value)
  # def decode(type, binary)
end
