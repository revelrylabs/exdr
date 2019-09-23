defmodule XDR.Type.Array do
  @moduledoc """
  A fixed-length array of some other type
  """

  defstruct type_name: "Array", length: nil, data_type: nil, values: []

  defimpl XDR.Type do
    def build_type(%{type_name: name} = type, options) do
      data_type = Keyword.get(options, :type)
      length = Keyword.get(options, :length)
      unless data_type && length do
        raise XDR.Error,
          message: ":length and :type options required for #{name}",
          type: name
      end
      %{type | data_type: data_type, length: length}
    end

    def resolve_type!(%{data_type: data_type} = type, %{} = custom_types) do
      %{type | data_type: XDR.Type.resolve_type!(data_type, custom_types)}
    end

    def build_value!(%{data_type: data_type, length: length, type_name: name} = type, raw_values)
        when is_list(raw_values) do
      unless length(raw_values) == length do
        raise XDR.Error,
          message: "Wrong length, expected #{length} values",
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
      values
      |> Enum.map(&XDR.Type.encode!/1)
      |> Enum.join()
    end

    def decode!(%{length: length, data_type: data_type} = type, encoding) do
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
