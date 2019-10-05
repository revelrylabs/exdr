defmodule XDR.Type.UnsignedIntTest do
  use ExUnit.Case
  alias XDR.Type.UnsignedInt

  setup_all do
    [type: XDR.build_type(UnsignedInt)]
  end

  test "handles reasonable values", %{type: int_type} do
    assert {:ok, int_with_value} = XDR.build_value(int_type, 123)
    assert {:ok, encoding} = XDR.encode(int_with_value)
    assert {:ok, decoded} = XDR.decode(int_type, encoding)

    assert XDR.extract_value(int_with_value) == {:ok, 123}
    assert decoded == int_with_value
  end

  test "errors on negative values", %{type: int_type} do
    assert {:error, error} = XDR.build_value(int_type, -123)
    assert error.message == "Invalid value"
  end
end

