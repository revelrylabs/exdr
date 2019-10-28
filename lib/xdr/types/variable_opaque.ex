defmodule XDR.Type.VariableOpaque do
  @moduledoc """
  Variable-length binary data
  """
  alias XDR.Size

  defstruct length: nil, max_length: Size.max(), type_name: "VariableOpaque", value: nil

  @type t() :: %__MODULE__{
          length: XDR.Size.t(),
          max_length: XDR.Size.t(),
          type_name: String.t(),
          value: binary()
        }
  @type encoding() :: <<_::_*32>>

  defimpl XDR.Type do
    def build_type(type, max_length) when is_integer(max_length) do
      if max_length > Size.max() do
        raise XDR.Error,
          message: "max length value must not be larger than #{Size.max()}",
          type: type.type_name
      end

      %{type | max_length: max_length}
    end

    def build_type(type, []) do
      type
    end

    def resolve_type!(type, _) do
      type
    end

    def build_value!(type, value) when is_binary(value) do
      len = byte_size(value)

      if len > type.max_length do
        raise XDR.Error,
          message: "value length is more than the maximum of #{type.max_length} bytes",
          type: type.type_name,
          data: value
      else
        %{type | length: len, value: value}
      end
    end

    def build_value!(%{type_name: type}, value) do
      raise XDR.Error, message: "value must be a binary", type: type, data: value
    end

    def extract_value!(%{value: value}), do: value

    def encode!(%{length: length, value: value})
        when is_integer(length) and is_binary(value) do
      Size.encode(length) <> value <> XDR.Padding.padding(length)
    end

    def encode!(_) do
      raise XDR.Error,
        message: "missing or malformed value or length",
        type: "VariableOpaque"
    end

    def decode!(type, encoding_with_length) do
      {length, encoding} = Size.decode!(encoding_with_length)
      padding_length = XDR.Padding.padding_length(length)

      <<value::binary-size(length), _padding::binary-size(padding_length), rest::binary>> =
        encoding

      type_with_value = build_value!(type, value)
      {type_with_value, rest}
    end
  end
end
