defmodule XDR.Type.Double do
  @moduledoc """
  Double-precision (32 bit) floating-point number
  """
  defstruct type_name: "Double", value: nil

  def encode(value) when is_float(value) do
    <<value::float-size(64)>>
  end

  def encode(%__MODULE__{value: value}) when is_float(value) do
    encode(value)
  end

  def decode!(<<value::float-size(64), rest::binary>>) do
    {value, rest}
  end

  def decode!(_) do
    raise "Ran out of bytes while trying to read a Double"
  end

  defimpl XDR.Type do
    alias XDR.Type.Double

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
      Double.encode(type_with_value)
    end

    def decode!(type, encoding) do
      {value, rest} = Double.decode!(encoding)
      type_with_value = build_value!(type, value)
      {type_with_value, rest}
    end
  end
end


