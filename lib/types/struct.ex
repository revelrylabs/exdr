defmodule XDR.Type.Struct do
  defstruct fields: [], type_name: "Struct"

  defimpl XDR.Type do
    def build_type(type, fields) when is_list(fields) do
      %{type | fields: fields}
    end

    def resolve_type!(type, %{} = custom_types) do
      resolved_fields =
        type.fields
        |> Enum.map(fn {key, sub_type} ->
          {key, XDR.Type.resolve_type!(sub_type, custom_types)}
        end)

      %{type | fields: resolved_fields}
    end

    def resolve_type(type, %{} = custom_types) do
      type = resolve_type!(type, %{} = custom_types)
      {:ok, type}
    rescue
      reason -> {:error, reason}
    end

    def build_value!(type, values) when is_list(values) do
      built_fields =
        type.fields
        |> Enum.map(fn {key, sub_type} -> {key, XDR.Type.build_value!(sub_type, values[key])} end)

      %{type | fields: built_fields}
    end

    def build_value(type, values) when is_list(values) do
      updated_type = build_value!(type, values)
      {:ok, updated_type}
    rescue
      reason -> {:error, reason}
    end

    def encode!(type_with_value) do
      type_with_value.fields
      |> Enum.map(&elem(&1, 1))
      |> Enum.map(&XDR.Type.encode!/1)
      |> Enum.join()
    end

    def encode(type_with_value) do
      {:ok, encode!(type_with_value)}
    rescue
      reason -> {:error, reason}
    end

    def decode!(type, struct_encoding) do
      {fields, rest} =
        Enum.map_reduce(type.fields, struct_encoding, fn {key, sub_type}, encoding ->
          {sub_type_with_value, rest} = XDR.Type.decode!(sub_type, encoding)
          {{key, sub_type_with_value}, rest}
        end)

      {%{type | fields: fields}, rest}
    end

    def decode(type, encoding) do
      {type_with_values, rest} = decode!(type, encoding)
      {:ok, type_with_values, rest}
    rescue
      reason -> {:error, reason}
    end
  end
end
