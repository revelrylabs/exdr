# these are the custom-defined types
defimpl XDR.Type, for: BitString do
  def resolve_type!(name, %{} = custom_types) do
    case Map.get(custom_types, name) do
      nil -> raise "type '#{name}' has not been defined"
      type -> XDR.Type.resolve_type!(%{type | type_name: name}, custom_types)
    end
  end

  def build_type(_, _) do
    raise "cannot build a custom type directly"
  end

  def build_value!(_, _) do
    raise "cannot build a value for an unresolved custom type"
  end

  def extract_value!(_) do
    raise "cannot extract an unresolved custom types"
  end

  def encode!(_) do
    raise "cannot encode an unresolved custom type"
  end

  def decode!(_, _) do
    raise "cannot decode an unresolved custom type"
  end
end
