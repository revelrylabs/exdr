defmodule XDR.Types do
  alias XDR.Type.{Int, Struct, VariableOpaque}

  def build_type(:int), do: Int.define_type()
  def build_type(:variable_opaque), do: VariableOpaque.define_type()
  def build_type(:struct, fields), do: Struct.define_type(fields)
  def build_type(:variable_opaque, max_len), do: VariableOpaque.define_type(max_len)
end
