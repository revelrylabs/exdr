defmodule XDR.Type.String do
  @moduledoc """
  Variable-length ASCII data
  This is almost the same as VariableOpaque, except the requirement that bytes
  be in the ASCII range
  """
  alias XDR.Size

  defstruct length: nil, max_length: Size.max(), type_name: "String", value: nil

  @type t() :: %__MODULE__{
    length: XDR.Size.t(),
    max_length: XDR.Size.t(),
    type_name: String.t(),
    value: binary()
  }
  @type encoding() :: <<_::_*32>>

  defimpl XDR.Type do
    alias XDR.Type.XDR.Type.VariableOpaque

    defdelegate build_type(type, opts), to: VariableOpaque
    defdelegate resolve_type!(type, custom_types), to: VariableOpaque
    defdelegate extract_value!(type_with_value), to: VariableOpaque
    defdelegate encode!(type_with_value), to: VariableOpaque

    def build_value!(type, value) when is_binary(value) do
      if !is_ascii(value) do
        raise XDR.Error,
          message: "Strings can only contain ASCII characters",
          type: type.type_name,
          data: value
      end
      VariableOpaque.build_value!(type, value)
    end

    def build_value!(%{type_name: type}, _) do
      raise XDR.Error, message: "value must be a binary", type: type
    end

    def decode!(type, encoding_with_length) do
      {%{value: value} = type_with_value, rest} = VariableOpaque.decode!(type, encoding_with_length)
      if !is_ascii(value) do
        raise XDR.Error,
          message: "Strings can only contain ASCII characters",
          type: type.type_name,
          data: value
      end
      {type_with_value, rest}
    end

    defp is_ascii(""), do: true
    defp is_ascii(<<head, tail::binary>>) when head < 128, do: is_ascii(tail)
    defp is_ascii(_), do: false
  end
end
