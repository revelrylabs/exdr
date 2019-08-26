defmodule XDR.Type.Union do
  # TODO: switch_type and switch_value could both be stored in one place
  # same with arms... we can store the value in the type of the selected arm
  # but naming gets kinda hard and annoying

  # TODO: default_arm
  # TODO: handle VOID
  defstruct arms: [],
            switches: [],
            switch_name: nil,
            switch_type: nil,
            switch_value: nil,
            type_name: "Union",
            value: nil

  def validate_type_options!(options) do
    options
    |> require!(:arms)
    |> require_list!(:arms)
    |> require!(:switches)
    |> require_list!(:switches)
    |> require!(:switch_type)
  end

  def get_value_type(type, switch_type_with_value) do
    type_value = XDR.extract_value!(switch_type_with_value)
    arm_key = type.switches[type_value]
    type.arms[arm_key]
  end

  defp require!(list, key) do
    if !Keyword.has_key?(list, key) do
      raise %XDR.Error{message: "key #{key} is required", data: list, type: "Union"}
    end

    list
  end

  defp require_list!(list, key) do
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

    def build_type(type, options) do
      Union.validate_type_options!(options)

      type
      |> Map.merge(%{
        arms: options[:arms],
        switches: options[:switches],
        switch_name: options[:switch_name] || nil,
        switch_type: options[:switch_type]
      })
    end

    def resolve_type!(type, %{} = custom_types) do
      arms =
        type.arms
        |> Enum.map(&resolve_type_wrap(&1, custom_types, :arms))

      switch_type = resolve_type_wrap(type.switch_type, custom_types, :switch_type)

      %{type | arms: arms, switch_type: switch_type}
    end

    def build_value!(type, {switch_raw, arm_raw}) do
      switch_value = build_value_wrap(type.switch_type, switch_raw, :switch_value)

      value =
        Union.get_value_type(type, switch_value)
        |> XDR.Type.build_value!(arm_raw)

      %{type | switch_value: switch_value, value: value}
    end

    def extract_value!(%{value: value}) do
      XDR.Type.extract_value!(value)
    end

    def encode!(%{switch_value: switch_value, value: value}) do
      switch_encoding = encode_wrap(switch_value, :switch_value)
      value_encoding = XDR.Type.encode!(value)
      switch_encoding <> value_encoding
    end

    def decode!(type, encoding) do
      {switch_value, switch_rest} = XDR.Type.decode!(type.switch_type, encoding)
      value_type = Union.get_value_type(type, switch_value)
      {value, rest} = XDR.Type.decode!(value_type, switch_rest)

      {%{type | switch_value: switch_value, value: value}, rest}
    end

    # private functions to handle wrapping & propagating errors

    defp wrap_error(error, key) do
      XDR.Error.wrap(error, key)
    end

    defp wrap_error(error, key, parent_key) do
      error
      |> wrap_error(key)
      |> wrap_error(parent_key)
    end

    defp resolve_type_wrap({key, sub_type}, custom_types, parent_key) do
      {key, XDR.Type.resolve_type!(sub_type, custom_types)}
    rescue
      error -> reraise wrap_error(error, key, parent_key), __STACKTRACE__
    end

    defp resolve_type_wrap(sub_type, custom_types, key) do
      XDR.Type.resolve_type!(sub_type, custom_types)
    rescue
      error -> reraise wrap_error(error, key), __STACKTRACE__
    end

    defp build_value_wrap(sub_type, value, key) do
      XDR.Type.build_value!(sub_type, value)
    rescue
      error -> reraise wrap_error(error, key), __STACKTRACE__
    end

    defp encode_wrap(sub_type, key) do
      XDR.Type.encode!(sub_type)
    rescue
      error -> reraise XDR.Error.wrap(error, key), __STACKTRACE__
    end
  end
end
