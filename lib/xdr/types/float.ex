defmodule XDR.Type.Float do
  @moduledoc """
  Single-precision (32 bit) floating-point number
  """
  defstruct type_name: "Float", value: nil

  @type value() :: float()
  @type t() :: %__MODULE__{type_name: String.t(), value: value()}
  @type encoding() :: <<_::32>>

  @doc """
  Encode the given float or `%XDR.Type.Float{}` as an 4-byte binary
  """
  @spec encode(value() | t()) :: encoding()
  def encode(value) when is_float(value) do
    <<value::float-size(32)>>
  end

  def encode(%__MODULE__{value: value}) when is_float(value) do
    encode(value)
  end

  @doc """
  Decode the first 4 bytes of the given binary as a single-precision float
  and return the value along with the reamining binary as a tuple
  """
  @spec decode!(<<_::32, _::_*8>>) :: {value(), binary()}
  def decode!(<<value::float-size(32), rest::binary>>) do
    {value, rest}
  end

  def decode!(_) do
    raise "Ran out of bytes while trying to read a Float"
  end

  defimpl XDR.Type do
    alias XDR.Type.Float

    def build_type(type, _), do: type

    def resolve_type!(type, _), do: type

    def build_value!(type, value) when is_float(value) do
      %{type | value: value}
    end

    def build_value!(%{type_name: name}, value) do
      raise XDR.Error, message: "Invalid value", type: name, data: value
    end

    def extract_value!(%{value: value}), do: value

    def encode!(type_with_value) do
      Float.encode(type_with_value)
    end

    def decode!(type, encoding) do
      {value, rest} = Float.decode!(encoding)
      type_with_value = build_value!(type, value)
      {type_with_value, rest}
    end
  end
end
