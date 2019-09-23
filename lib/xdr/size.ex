defmodule XDR.Size do
  @moduledoc """
  Size utilities for various types
  """
  @max trunc(:math.pow(2, 32) - 1)

  defdelegate encode(type_with_size), to: XDR.Type.UnsignedInt
  defdelegate decode!(encoding), to: XDR.Type.UnsignedInt

  def max() do
    @max
  end
end
