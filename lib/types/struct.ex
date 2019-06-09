defmodule XDR.Type.Struct do
  defstruct fields: [], type_name: "Struct"

  def define_type(fields) do
    %__MODULE__{fields: fields}
  end

  defimpl XDR.Type do
    def resolve_type!(type, %{} = custom_types) do
      resolved_fields =
        type.fields
        |> Enum.map(fn {key, sub_type} ->
          {key, XDR.Type.resolve_type!(sub_type, custom_types)}
        end)

      %{type | fields: resolved_fields}
    end

    def resolve_type(type, %{} = custom_types) do
      type = resolve_type!(type, %{} = custom_types)
      {:ok, type}
    rescue
      reason -> {:error, reason}
    end

    def build_value!(type, values) when is_list(values) do
      built_fields =
        type.fields
        |> Enum.map(fn {key, sub_type} -> {key, XDR.Type.build_value!(sub_type, values[key])} end)

      %{type | fields: built_fields}
    end

    def build_value(type, values) when is_list(values) do
      updated_type = build_value!(type, values)
      {:ok, updated_type}
    rescue
      reason -> {:error, reason}
    end
  end
end
