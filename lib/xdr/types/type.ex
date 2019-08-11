defprotocol XDR.Type do
  def build_type(type, options)
  def resolve_type!(type, custom_types)
  def build_value!(type, value)
  def encode!(type_with_value)
  def decode!(type, encoding)
  def extract_value!(type_with_values)
end
