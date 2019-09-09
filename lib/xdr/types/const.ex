defmodule XDR.Type.Const do
  @moduledoc """
  Const: not really an XDR data type, but they can be declared the same way
  """

  defstruct type_name: "Const", value: nil

  defimpl XDR.Type do
    def build_type(type, value), do: %{type | value: value}

    def resolve_type!(type, _), do: type

    def build_value!(type, _value), do: type

    def extract_value!(%{value: value}), do: value

    def encode!(%{type_name: type}) do
      raise XDR.Error,
        message: "Cannot encode a constant. Use it only to build the value of another type",
        type: type
    end

    def decode!(%{type_name: type}, _encoding) do
      raise XDR.Error,
        message: "Cannot decode a constant. Use it only to build the value of another type",
        type: type
    end
  end
end
