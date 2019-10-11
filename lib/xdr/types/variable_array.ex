defmodule XDR.Type.VariableArray do
  @moduledoc """
  A variable-length array of some other type
  """
  alias XDR.Size

  defstruct type_name: "VariableArray", data_type: nil, max_length: Size.max(), values: []

  @type t() :: %__MODULE__{
          type_name: String.t(),
          data_type: XDR.Type.t(),
          max_length: XDR.Size.t(),
          values: list(XDR.Type.t())
        }
  @type options() :: [type: XDR.Type.key(), max_length: XDR.Size.t()]

  defimpl XDR.Type do
    def build_type(type, type: data_type, max_length: max_length) when is_integer(max_length) do
      %{type | data_type: data_type, max_length: max_length}
    end

    def build_type(type, options) do
      build_type(type, Keyword.merge(options, max_length: Size.max()))
    end

    def resolve_type!(%{data_type: data_type} = type, %{} = custom_types) do
      %{type | data_type: XDR.Type.resolve_type!(data_type, custom_types)}
    end

    def build_value!(
          %{data_type: data_type, max_length: max_length, type_name: name} = type,
          raw_values
        )
        when is_list(raw_values) do
      if length(raw_values) > max_length do
        raise XDR.Error,
          message: "Input values too long, expected a max of #{max_length} values",
          type: name,
          data: raw_values
      end

      values = Enum.map(raw_values, fn value -> XDR.build_value!(data_type, value) end)
      %{type | values: values}
    end

    def extract_value!(%{values: values}) do
      Enum.map(values, fn value -> XDR.Type.extract_value!(value) end)
    end

    def encode!(%{values: values}) do
      encoded_length = Size.encode(length(values))

      encoded_values =
        values
        |> Enum.map(&XDR.Type.encode!/1)
        |> Enum.join()

      encoded_length <> encoded_values
    end

    def decode!(%{data_type: data_type} = type, full_encoding) do
      {length, encoding} = Size.decode!(full_encoding)

      {reversed_values, rest} =
        1..length
        |> Enum.reduce({[], encoding}, fn _, {vals, prev_rest} ->
          {current_value, next_rest} = XDR.Type.decode!(data_type, prev_rest)
          {[current_value | vals], next_rest}
        end)

      {%{type | values: Enum.reverse(reversed_values)}, rest}
    end
  end
end
