defmodule XDR.Type.Optional do
  @moduledoc """
  Optional
  """

  defstruct type_name: "Optional", switch: %XDR.Type.Bool{}, data_type: nil, value: nil

  @type t() :: %__MODULE__{type_name: String.t(), switch: XDR.Type.Bool.t(), data_type: XDR.Type.t(), value: XDR.Type.t()}
  @type value() :: {boolean(), any()} | false | nil | any()

  defimpl XDR.Type do
    def build_type(type, data_type), do: %{type | data_type: data_type}

    def resolve_type!(%{data_type: data_type} = type, %{} = custom_types) do
      %{type | data_type: XDR.Type.resolve_type!(data_type, custom_types)}
    end

    def build_value!(%{data_type: data_type, switch: switch} = type, {true, value}) do
      %{type | switch: XDR.build_value!(switch, true), value: XDR.build_value!(data_type, value)}
    end

    def build_value!(%{switch: switch} = type, {false, _}) do
      %{type | switch: XDR.build_value!(switch, false), value: %XDR.Type.Void{}}
    end

    def build_value!(type, nil) do
      build_value!(type, {false, nil})
    end

    def build_value!(type, false) do
      build_value!(type, {false, nil})
    end

    def build_value!(type, val) do
      build_value!(type, {true, val})
    end

    def extract_value!(%{value: value}), do: XDR.Type.extract_value!(value)

    def encode!(%{switch: switch, value: value}) do
      XDR.encode!(switch) <> XDR.encode!(value)
    end

    def decode!(type, encoding) do
      {switch, switch_rest} = XDR.Type.decode!(type.switch, encoding)

      {value, rest} =
        if XDR.extract_value!(switch) do
          XDR.Type.decode!(type.data_type, switch_rest)
        else
          XDR.Type.decode!(%XDR.Type.Void{}, switch_rest)
        end

      {%{type | switch: switch, value: value}, rest}
    end
  end
end
