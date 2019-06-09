# these are the custom-defined types
defimpl XDR.Type, for: BitString do
  def resolve_type(name, %{} = custom_types) do
    case Map.get(custom_types, name) do
      nil -> {:error, "type '#{name}' has not been defined"}
      type -> XDR.Type.resolve_type(%{type | type_name: name}, custom_types)
    end
  end

  def resolve_type!(name, %{} = custom_types) do
    case resolve_type(name, custom_types) do
      {:ok, type} -> type
      {:error, reason} -> raise reason
    end
  end

  def build_value(_, _) do
    {:error, "cannot build a value for an unresolved custom type"}
  end

  def build_value!(type, value) do
    {:error, reason} = build_value(type, value)
    raise reason
  end
end
