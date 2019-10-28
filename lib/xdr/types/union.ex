defmodule XDR.Type.Union do
  @moduledoc """
  A Union is a polymorphic type.
  It has a _switch_ of type enum or int, whose value determines the type of the union's data.

  ### TODO
  - finish support for a default arm
  """

  defstruct arms: [],
            switches: [],
            switch_name: nil,
            switch: nil,
            type_name: "Union",
            default_arm: nil,
            value: nil

  @type switch_value() :: atom() | integer()
  @type switch() :: {switch_value(), atom() | XDR.Void | XDR.Void.t()}
  @type options() :: [
          arms: keyword(XDR.Type.t()),
          switch_name: String.t() | atom(),
          switch_type: XDR.Type.t(),
          switches: list(switch()),
          default_arm: atom()
        ]
  @type t() :: %__MODULE__{
          arms: list(XDR.Type.t()),
          switches: list(switch()),
          switch_name: String.t() | atom() | nil,
          type_name: String.t(),
          default_arm: atom() | nil,
          value: XDR.Type.t()
        }
  @type value() :: {switch_value(), any()} | switch_value()

  def validate_type_options!(options) do
    options
    |> require!(:arms)
    |> require_keyword_list!(:arms)
    |> require!(:switches)
    |> require_list!(:switches)
    |> require!(:switch_type)
  end

  def get_value_type(type, switch_type_with_value) do
    type_value = XDR.extract_value!(switch_type_with_value)
    {_switch_val, arm_key} = Enum.find(type.switches, fn {key, _val} -> key == type_value end)

    case arm_key do
      XDR.Type.Void -> struct(arm_key)
      %XDR.Type.Void{} -> arm_key
      _ -> type.arms[arm_key]
    end
  end

  defp require!(list, key) do
    if !Keyword.has_key?(list, key) do
      raise %XDR.Error{message: "key #{key} is required", data: list, type: "Union"}
    end

    list
  end

  defp require_list!(list, key) do
    if !is_list(list[key]) do
      raise %XDR.Error{
        message: "value of #{key} must be a list",
        data: list[key],
        type: "Union"
      }
    end

    list
  end

  defp require_keyword_list!(list, key) do
    if !Keyword.keyword?(list[key]) do
      raise %XDR.Error{
        message: "value of #{key} must be a keyword list",
        data: list[key],
        type: "Union"
      }
    end

    list
  end

  defimpl XDR.Type do
    alias XDR.Type.Union
    alias XDR.Error

    def build_type(type, options) do
      Union.validate_type_options!(options)

      type
      |> Map.merge(%{
        arms: options[:arms],
        switches: options[:switches],
        switch_name: options[:switch_name] || nil,
        switch: options[:switch_type],
        default_arm: options[:default_arm] || nil
      })
    end

    def resolve_type!(type, %{} = custom_types) do
      arms =
        Enum.map(type.arms, fn {key, sub_type} ->
          {key, Error.wrap_call(XDR.Type, :resolve_type!, [sub_type, custom_types], [key, :arms])}
        end)

      switch_type =
        Error.wrap_call(
          XDR.Type,
          :resolve_type!,
          [type.switch, custom_types],
          :switch_type
        )

      %{type | arms: arms, switch: switch_type}
    end

    def build_value!(type, {switch_raw, arm_raw}) do
      switch_value = Error.wrap_call(:build_value!, [type.switch, switch_raw], :switch_value)
      value_type = Union.get_value_type(type, switch_value)
      value = XDR.build_value!(value_type, arm_raw)

      %{type | switch: switch_value, value: value}
    end

    # Just supply the switch value to use the Void arm
    def build_value!(type, switch_raw), do: build_value!(type, {switch_raw, nil})

    def extract_value!(%{value: value}) do
      XDR.Type.extract_value!(value)
    end

    def encode!(%{switch: switch_value, value: value}) do
      switch_encoding = Error.wrap_call(:encode!, [switch_value], :switch_value)
      value_encoding = XDR.Type.encode!(value)
      switch_encoding <> value_encoding
    end

    def decode!(type, encoding) do
      {switch_value, switch_rest} = XDR.Type.decode!(type.switch, encoding)
      value_type = Union.get_value_type(type, switch_value)
      {value, rest} = XDR.Type.decode!(value_type, switch_rest)

      {%{type | switch: switch_value, value: value}, rest}
    end
  end
end
