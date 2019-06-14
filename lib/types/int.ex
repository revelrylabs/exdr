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
    {:errro, "invalid int encoding"}
  end

  defimpl XDR.Type do
    def build_type(type, _options \\ []) do
      type
    end

    def resolve_type(type, _) do
      {:ok, type}
    end

    def resolve_type!(type, _) do
      type
    end

    @doc ~S"""
    Builds an Int value

    ## Examples

        iex> XDR.Type.build_value(%XDR.Type.Int{}, "what")
        {:error, "'what' is not a valid value for 'Int'"}

        iex> XDR.Type.build_value(%XDR.Type.Int{type_name: "Number"}, "what")
        {:error, "'what' is not a valid value for 'Number'"}

        iex> XDR.Type.build_value(%XDR.Type.Int{}, 123)
        {:ok, %XDR.Type.Int{value: 123}}

    """
    def build_value(type, value) when is_integer(value) do
      {:ok, %{type | value: value}}
    end

    def build_value(%{type_name: name}, value) do
      {:error, "'#{value}' is not a valid value for '#{name}'"}
    end

    def build_value!(type, value) do
      case build_value(type, value) do
        {:error, reason} -> raise reason
        {:ok, updated_type} -> updated_type
      end
    end

    def encode(type_with_value) do
      {:ok, encode!(type_with_value)}
    end

    def encode!(type_with_value) do
      XDR.Type.Int.encode(type_with_value)
    end

    def decode(type, encoding) do
      with {:ok, value, rest} <- XDR.Type.Int.decode(encoding),
           {:ok, type_with_value} <- build_value(type, value) do
        {:ok, type_with_value, rest}
      else
        error -> error
      end
    end

    def decode!(type, encoding) do
      case decode(type, encoding) do
        {:ok, encoded_type, rest} -> {encoded_type, rest}
        {:error, reason} -> raise reason
      end
    end
  end
end
