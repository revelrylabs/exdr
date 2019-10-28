defmodule XDR.Type.Struct do
  @moduledoc """
  Struct with each atom key pointing to an XDR type of its own
  """
  defstruct fields: [], type_name: "Struct"

  @type fields() :: keyword(XDR.Type.t())
  @type t() :: %__MODULE__{type_name: String.t(), fields: fields()}

  defimpl XDR.Type do
    alias XDR.Error

    def build_type(type, fields) when is_list(fields) do
      %{type | fields: fields}
    end

    def resolve_type!(type, %{} = custom_types) do
      resolved_fields =
        Enum.map(type.fields, fn {key, sub_type} ->
          {key, Error.wrap_call(XDR.Type, :resolve_type!, [sub_type, custom_types], key)}
        end)

      %{type | fields: resolved_fields}
    end

    def build_value!(type, values) when is_list(values) do
      built_fields =
        Enum.map(type.fields, fn {key, sub_type} ->
          {key, Error.wrap_call(:build_value!, [sub_type, values[key]], key)}
        end)

      %{type | fields: built_fields}
    end

    def extract_value!(%{fields: fields}) do
      field_values =
        Enum.map(fields, fn {key, sub_value} ->
          {key, Error.wrap_call(:extract_value!, [sub_value], key)}
        end)

      field_values
    end

    def encode!(type_with_value) do
      type_with_value.fields
      |> Enum.map(fn {key, sub_value} ->
        Error.wrap_call(:encode!, [sub_value], key)
      end)
      |> Enum.join()
    end

    def decode!(type, struct_encoding) do
      {fields, rest} = Enum.map_reduce(type.fields, struct_encoding, &decode_wrap/2)

      {%{type | fields: fields}, rest}
    end

    defp decode_wrap({key, sub_type}, encoding) do
      {sub_type_with_value, rest} = Error.wrap_call(XDR.Type, :decode!, [sub_type, encoding], key)
      {{key, sub_type_with_value}, rest}
    end
  end
end
