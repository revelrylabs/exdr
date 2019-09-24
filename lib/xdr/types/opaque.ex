defmodule XDR.Type.Opaque do
  @moduledoc """
  Fixed-length binary data
  """
  alias XDR.Size

  defstruct length: nil, type_name: "Opaque", value: nil

  defimpl XDR.Type do
    def build_type(type, length) when is_integer(length) do
      if length > Size.max() do
        raise XDR.Error,
          message: "length value must not be larger than #{Size.max()}",
          type: type.type_name
      end

      %{type | length: length}
    end

    def resolve_type!(type, _) do
      type
    end

    def build_value!(type, value) when is_binary(value) do
      if byte_size(value) != type.length do
        raise XDR.Error,
          message: "value must be #{type.length} bytes",
          type: type.type_name,
          data: value
      else
        %{type | value: value}
      end
    end

    def build_value!(%{type_name: type}, _) do
      raise XDR.Error, message: "value must be a binary", type: type
    end

    def extract_value!(%{value: value}), do: value

    def encode!(%{length: length, value: value})
        when is_integer(length) and is_binary(value) do
      value <> XDR.padding(length)
    end

    def encode!(type) do
      raise XDR.Error,
        message: "missing or malformed value or length",
        type: type.type_name,
        data: type
    end

    def decode!(%{length: length} = type, encoding) do
      padding_length = XDR.padding_length(length)

      <<value::binary-size(length), _padding::binary-size(padding_length), rest::binary>> =
        encoding

      type_with_value = build_value!(type, value)
      {type_with_value, rest}
    end
  end
end

