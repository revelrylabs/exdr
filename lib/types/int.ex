defmodule XDR.Type.Int do
  defstruct type_name: "Int", value: nil

  def define_type() do
    %__MODULE__{}
  end

  defimpl XDR.Type do
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
  end
end
