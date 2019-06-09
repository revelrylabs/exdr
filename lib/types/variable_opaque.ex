defmodule XDR.Type.VariableOpaque do
  @max trunc(:math.pow(2, 32) - 1)

  defstruct length: nil, max_len: @max, type_name: "VariableOpaque", value: nil

  def define_type() do
    %__MODULE__{}
  end

  def define_type(max_len) when is_integer(max_len) do
    if max_len > @max do
      raise ArgumentError, message: "max length value must not be larger than #{@max}"
    end

    %__MODULE__{max_len: max_len}
  end

  defimpl XDR.Type do
    def resolve_type(type, _) do
      {:ok, type}
    end

    def resolve_type!(type, _) do
      type
    end

    def build_value(type, value) when is_binary(value) do
      len = String.length(value)

      if len > type.max_len do
        {:error, "value length is more than the maximum of #{type.max_len} bytes"}
      else
        {:ok, %{type | length: len, value: value}}
      end
    end

    def build_value(_, _) do
      {:error, "values must be a binary"}
    end

    def build_value!(type, value) when is_binary(value) do
      case build_value(type, value) do
        {:ok, updated_type} -> updated_type
        {:error, reason} -> raise reason
      end
    end
  end
end
