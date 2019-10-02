defmodule XDR.Type.Bool do
  @moduledoc """
  Boolean
  values are presented in Elixir as true / false and encoded as 1 / 0
  """

  defstruct type_name: "Bool", value: nil

  @type value() :: boolean()
  @type t() :: %__MODULE__{ type_name: String.t(), value: value()}
  @type encoding() :: <<_::32>>

  defimpl XDR.Type do
    alias XDR.Type.Int

    def build_type(type, _options \\ []) do
      type
    end

    def resolve_type!(type, _) do
      type
    end

    def build_value!(type, value) when is_boolean(value) do
      %{type | value: value}
    end

    def build_value!(%{type_name: name}, value) do
      raise XDR.Error, message: "Invalid value", type: name, data: value
    end

    def extract_value!(%{value: value}), do: value

    def encode!(%{value: true}), do: Int.encode(1)
    def encode!(%{value: false}), do: Int.encode(0)

    def decode!(type, encoding) do
      {value, rest} = Int.decode!(encoding)
      type_with_value = build_value!(type, value == 1)
      {type_with_value, rest}
    end
  end
end
