defmodule XDR.Type.HyperInt do
  @moduledoc """
  Signed 64-bit integer
  """
  defstruct type_name: "HyperInt", value: nil

  @type value() :: -0x80000000_00000000..0x7FFFFFFF_FFFFFFFF
  @type t() :: %__MODULE__{type_name: String.t(), value: value()}
  @type encoding() :: <<_::64>>

  @doc """
  Encode the given integer or `XDR.Type.HyperInt` struct as an 8-byte binary
  """
  @spec encode(value() | t()) :: encoding()
  def encode(value) when is_integer(value) do
    <<value::big-signed-integer-size(64)>>
  end

  def encode(%__MODULE__{value: value}) when is_integer(value) do
    encode(value)
  end

  @doc """
  Decode the first 8 bytes of the binary as a hyperint and return that value
  along with the rest of the binary in a tuple
  """
  @spec decode!(<<_::64, _::_*8>>) :: {value(), binary()}
  def decode!(<<value::big-signed-integer-size(64), rest::binary>>) do
    {value, rest}
  end

  def decode!(_) do
    raise "Ran out of bytes while trying to read a HyperInt"
  end

  defimpl XDR.Type do
    alias XDR.Type.HyperInt

    def build_type(type, _), do: type

    def resolve_type!(type, _), do: type

    def build_value!(type, value) when is_integer(value) do
      %{type | value: value}
    end

    def build_value!(%{type_name: name}, value) do
      raise XDR.Error, message: "Invalid value", type: name, data: value
    end

    def extract_value!(%{value: value}), do: value

    def encode!(type_with_value) do
      HyperInt.encode(type_with_value)
    end

    def decode!(type, encoding) do
      {value, rest} = HyperInt.decode!(encoding)
      type_with_value = build_value!(type, value)
      {type_with_value, rest}
    end
  end
end
