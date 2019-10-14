defmodule XDR.Type.Array do
  @moduledoc """
  A fixed-length array of some other type
  """

  defstruct type_name: "Array", length: nil, data_type: nil, values: []

  @type t() :: %__MODULE__{
          type_name: String.t(),
          length: XDR.Size.t(),
          data_type: XDR.Type.t(),
          values: list(XDR.Type.t())
        }
  @type options() :: [type: XDR.Type.t(), length: XDR.Size.t()]

  defimpl XDR.Type do
    alias XDR.Error

    def build_type(%{type_name: name} = type, options) do
      data_type = Keyword.get(options, :type)
      length = Keyword.get(options, :length)

      unless data_type && XDR.Size.valid?(length) do
        raise Error,
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
        raise Error,
          message: "Wrong length, expected #{length} values",
          type: name,
          data: raw_values
      end

      values =
        raw_values
        |> Enum.with_index()
        |> Enum.map(fn {value, index} ->
          Error.wrap_call(:build_value!, [data_type, value], index)
        end)

      %{type | values: values}
    end

    def extract_value!(%{values: values}) do
      values
      |> Enum.with_index()
      |> Enum.map(fn {value, index} ->
        Error.wrap_call(:extract_value!, [value], index)
      end)
    end

    def encode!(%{values: values}) do
      values
      |> Enum.with_index()
      |> Enum.map(fn {value, index} ->
        Error.wrap_call(:encode!, [value], index)
      end)
      |> Enum.join()
    end

    def decode!(%{length: length, data_type: data_type} = type, encoding) do
      {reversed_values, rest} =
        0..(length - 1)
        |> Enum.reduce({[], encoding}, fn index, {vals, prev_rest} ->
          {current_value, next_rest} =
            Error.wrap_call(XDR.Type, :decode!, [data_type, prev_rest], index)

          {[current_value | vals], next_rest}
        end)

      {%{type | values: Enum.reverse(reversed_values)}, rest}
    end
  end
end
