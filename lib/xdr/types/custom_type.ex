# these are the custom-defined types
defmodule XDR.Type.CustomType do
  @moduledoc """
  A custom type is referenced by its name, as a bit string / binary
  """

  @typedoc """
  A custom type is referenced by its name, as a bit string / binary
  """
  @type t() :: String.t()
  @type type_map() :: %{String.t() => XDR.Type.t()}

  @doc """
  Add a new type to the map, which is usually stored in a module that `use`s `XDR.Base`
  The map serves a a lookup from friendly type names to fully-defined `XDR.Type.t()` values
  """
  @spec register_type(type_map(), String.t(), XDR.Type.t(), XDR.ignored()) :: type_map()
  def register_type(custom_types, alias_name, base_type, _options) when is_binary(base_type) do
    Map.put(custom_types, alias_name, base_type)
  end

  def register_type(custom_types, name, base_type, options) do
    type = XDR.build_type(base_type, options)
    Map.put(custom_types, name, type)
  end
end

defimpl XDR.Type, for: BitString do
  def resolve_type!(name, %{} = custom_types) do
    case Map.get(custom_types, name) do
      nil -> raise "type '#{name}' has not been defined"
      <<_::binary>> = type -> XDR.Type.resolve_type!(type, custom_types)
      %{} = type -> XDR.Type.resolve_type!(%{type | type_name: name}, custom_types)
    end
  end

  def build_type(_, _) do
    raise "cannot build a custom type directly"
  end

  def build_value!(_, _) do
    raise "cannot build a value for an unresolved custom type"
  end

  def extract_value!(_) do
    raise "cannot extract an unresolved custom type"
  end

  def encode!(_) do
    raise "cannot encode an unresolved custom type"
  end

  def decode!(_, _) do
    raise "cannot decode an unresolved custom type"
  end
end
