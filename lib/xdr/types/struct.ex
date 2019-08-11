defmodule XDR.Type.Struct do
  defstruct fields: [], type_name: "Struct"

  defimpl XDR.Type do
    def build_type(type, fields) when is_list(fields) do
      %{type | fields: fields}
    end

    def resolve_type!(type, %{} = custom_types) do
      resolved_fields =
        type.fields
        |> Enum.map(&resolve_type_wrap(&1, custom_types))

      %{type | fields: resolved_fields}
    end

    def build_value!(type, values) when is_list(values) do
      built_fields =
        type.fields
        |> Enum.map(&build_value_wrap(&1, values))

      %{type | fields: built_fields}
    end

    def extract_value!(%{fields: fields}) do
      field_values =
        fields
        |> Enum.map(&extract_value_wrap/1)

      field_values
    end

    def encode!(type_with_value) do
      type_with_value.fields
      |> Enum.map(&encode_wrap/1)
      |> Enum.join()
    end

    def decode!(type, struct_encoding) do
      {fields, rest} = Enum.map_reduce(type.fields, struct_encoding, &decode_wrap/2)

      {%{type | fields: fields}, rest}
    end

    # private functions to handle wrapping & propagating errors

    defp resolve_type_wrap({key, sub_type}, custom_types) do
      {key, XDR.Type.resolve_type!(sub_type, custom_types)}
    rescue
      error -> reraise XDR.Error.wrap(error, key), __STACKTRACE__
    end

    defp build_value_wrap({key, sub_type}, values) do
      {key, XDR.Type.build_value!(sub_type, values[key])}
    rescue
      error -> reraise XDR.Error.wrap(error, key), __STACKTRACE__
    end

    defp extract_value_wrap({key, sub_type}) do
      {key, XDR.Type.extract_value!(sub_type)}
    rescue
      error -> reraise XDR.Error.wrap(error, key), __STACKTRACE__
    end

    defp encode_wrap({key, sub_type}) do
      XDR.Type.encode!(sub_type)
    rescue
      error -> reraise XDR.Error.wrap(error, key), __STACKTRACE__
    end

    defp decode_wrap({key, sub_type}, encoding) do
      {sub_type_with_value, rest} = XDR.Type.decode!(sub_type, encoding)
      {{key, sub_type_with_value}, rest}
    rescue
      error -> reraise XDR.Error.wrap(error, key), __STACKTRACE__
    end
  end
end
