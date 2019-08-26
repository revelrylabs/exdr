defmodule XDR.Type.Enum do
  @moduledoc """
  Enum
  """

  defstruct options: [], value: nil, type_name: "Enum"

  defimpl XDR.Type do
    def build_type(type, options) when is_list(options) do
      # TODO: validate that all values are ints?
      %{type | options: options}
    end

    def resolve_type!(type, _), do: type

    def build_value!(type, value) do
      if Keyword.has_key?(type.options, value) do
        %{type | value: value}
      else
        raise XDR.Error, message: "invalid value #{inspect(value)}", type: type.type_name
      end
    end

    def extract_value!(%{value: value}), do: value

    def encode!(%{options: options, value: value}) do
      options
      |> Keyword.get(value)
      |> XDR.Type.Int.encode()
    end

    def decode!(type, encoding) do
      {int_val, rest} = XDR.Type.Int.decode!(encoding)
      value =
        type.options
        |> Enum.find(fn {_key, val} -> val == int_val end)
        |> elem(0)

      {%{type | value: value}, rest}
    end
  end
end

