defmodule XDR.Type.IntTest do
  use ExUnit.Case
  alias XDR.Type.Int

  setup_all do
    [type: XDR.build_type(Int)]
  end

  test "handles reasonable values", %{type: int_type} do
    {:ok, int_with_value} = XDR.build_value(int_type, 123)
    {:ok, encoding} = XDR.encode(int_with_value)
    {:ok, decoded} = XDR.decode(int_type, encoding)

    assert XDR.extract_value(int_with_value) == {:ok, 123}
    assert decoded == int_with_value
  end

  test "handles negative values", %{type: int_type} do
    {:ok, int_with_value} = XDR.build_value(int_type, -123)
    {:ok, encoding} = XDR.encode(int_with_value)
    {:ok, decoded} = XDR.decode(int_type, encoding)

    assert XDR.extract_value(int_with_value) == {:ok, -123}
    assert decoded == int_with_value
  end
end
