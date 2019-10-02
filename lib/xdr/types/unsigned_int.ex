defmodule XDR.Type.UnsignedInt do
  @moduledoc """
  Unsigned 32-bit integer
  """
  defstruct type_name: "UnsignedInt", value: nil

  @type value() :: 0..0xffffffff
  @type t() :: %__MODULE__{ type_name: String.t(), value: value()}
  @type encoding() :: <<_::32>>

  @doc """
  Encode the integer as a 32-byte binary
  """
  @spec encode(integer() | t()) :: encoding()
  def encode(value) when is_integer(value) do
    <<value::big-unsigned-integer-size(32)>>
  end

  def encode(%__MODULE__{value: value}) when is_integer(value) do
    encode(value)
  end

  @spec decode!(<<_::32, _::_*8>>) :: {value(), binary()}
  def decode!(<<value::big-unsigned-integer-size(32), rest::binary>>) do
    {value, rest}
  end

  def decode!(_) do
    raise "Ran out of bytes while trying to read an UnsignedInt"
  end

  defimpl XDR.Type do
    alias XDR.Type.UnsignedInt

    def build_type(type, _), do: type

    def resolve_type!(type, _), do: type

    def build_value!(type, value) when is_integer(value) and value >= 0 do
      %{type | value: value}
    end

    def build_value!(%{type_name: name}, value) do
      raise XDR.Error, message: "Invalid value", type: name, data: value
    end

    def extract_value!(%{value: value}), do: value

    def encode!(type_with_value) do
      UnsignedInt.encode(type_with_value)
    end

    def decode!(type, encoding) do
      {value, rest} = UnsignedInt.decode!(encoding)
      type_with_value = build_value!(type, value)
      {type_with_value, rest}
    end
  end
end
