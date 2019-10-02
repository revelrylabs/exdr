defmodule XDR.Type.Void do
  @moduledoc """
  Void
  """

  defstruct type_name: "Void"

  @type t() :: %__MODULE__{type_name: String.t()}
  @type encoding() :: <<>>

  defimpl XDR.Type do
    def build_type(type, _), do: type

    def resolve_type!(type, _), do: type

    def build_value!(type, _value), do: type

    def extract_value!(_type), do: nil

    def encode!(_), do: ""

    def decode!(type, encoding), do: {type, encoding}
  end
end
