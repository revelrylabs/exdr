defmodule XDR.Type.Int do
  defstruct type_name: "Int", value: nil

  def encode(value) when is_integer(value) do
    <<value::big-signed-integer-size(32)>>
  end

  def encode(%__MODULE__{value: value}) when is_integer(value) do
    encode(value)
  end

  def decode(<<value::big-signed-integer-size(32), rest::binary>>) do
    {:ok, value, rest}
  end

  def decode(_) do
    {:error, "Invalid encoding"}
  end

  defimpl XDR.Type do
    def build_type(type, _options \\ []) do
      type
    end

    def resolve_type!(type, _) do
      type
    end

    def build_value!(type, value) when is_integer(value) do
      %{type | value: value}
    end

    def build_value!(%{type_name: name}, value) do
      raise XDR.Error, message: "Invalid value", type: name, data: value
    end

    def extract_value!(%{value: value}), do: value

    def encode!(type_with_value) do
      XDR.Type.Int.encode(type_with_value)
    end

    def decode!(type, encoding) do
      with {:ok, value, rest} <- XDR.Type.Int.decode(encoding),
           type_with_value <- build_value!(type, value) do
        {type_with_value, rest}
      else
        {:error, message} ->
          raise XDR.Error,
            message: message,
            type: type.type_name,
            data: encoding
      end
    end
  end
end
