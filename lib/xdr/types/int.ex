defmodule XDR.Type.Int do
  @moduledoc """
  Signed 32-bit integer
  """
  defstruct type_name: "Int", value: nil

  @type value() :: -0x80000000..0x7fffffff
  @type t() :: %__MODULE__{ type_name: String.t(), value: value()}
  @type encoding() :: <<_::32>>

  @spec encode(value() | t()) :: encoding()
  def encode(value) when is_integer(value) do
    <<value::big-signed-integer-size(32)>>
  end

  def encode(%__MODULE__{value: value}) when is_integer(value) do
    encode(value)
  end

  @spec decode!(<<_::32, _::_*8>>) :: {value(), binary()}
  def decode!(<<value::big-signed-integer-size(32), rest::binary>>) do
    {value, rest}
  end

  def decode!(_) do
    raise "Ran out of bytes while trying to read an Int"
  end

  defimpl XDR.Type do
    alias XDR.Type.Int

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
      Int.encode(type_with_value)
    end

    def decode!(type, encoding) do
      {value, rest} = Int.decode!(encoding)
      type_with_value = build_value!(type, value)
      {type_with_value, rest}
    end
  end
end
