defprotocol XDR.Type do
  def resolve_type(type, custom_types)
  def resolve_type!(type, custom_types)
  def build_value(type, value)
  def build_value!(type, value)
  def encode(type_with_value)
  def encode!(type_with_value)
  def decode(type, encoding)
  def decode!(type, encoding)
end
