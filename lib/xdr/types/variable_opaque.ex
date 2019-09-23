defmodule XDR.Type.VariableOpaque do
  @moduledoc """
  Variable-length binary data
  """
  alias XDR.Size

  defstruct length: nil, max_len: Size.max(), type_name: "VariableOpaque", value: nil

  defimpl XDR.Type do
    def build_type(type, max_len) when is_integer(max_len) do
      if max_len > Size.max() do
        raise XDR.Error,
          message: "max length value must not be larger than #{Size.max()}",
          type: type.type_name
      end

      %{type | max_len: max_len}
    end

    def build_type(type, []) do
      type
    end

    def resolve_type!(type, _) do
      type
    end

    def build_value!(type, value) when is_binary(value) do
      len = byte_size(value)

      if len > type.max_len do
        raise XDR.Error,
          message: "value length is more than the maximum of #{type.max_len} bytes",
          type: type.type_name,
          data: value
      else
        %{type | length: len, value: value}
      end
    end

    def build_value!(%{type_name: type}, _) do
      raise XDR.Error, message: "value must be a binary", type: type
    end

    def extract_value!(%{value: value}), do: value

    def encode!(%{length: length, value: value})
        when is_integer(length) and is_binary(value) do
      Size.encode(length) <> value <> XDR.padding(length)
    end

    def encode!(_) do
      raise XDR.Error,
        message: "missing or malformed value or length",
        type: "VariableOpaque"
    end

    def decode!(type, encoding_with_length) do
      {length, encoding} = Size.decode!(encoding_with_length)
      padding_length = XDR.padding_length(length)

      <<value::binary-size(length), _padding::binary-size(padding_length), rest::binary>> =
        encoding

      type_with_value = build_value!(type, value)
      {type_with_value, rest}
    end
  end
end
