defmodule XDR.Type.ConstTest do
  use ExUnit.Case
  alias XDR.Type.Const

  @const_int XDR.build_type(Const, 123)

  describe "XDR interface" do
    test "build_value doesn't do anything" do
      assert XDR.Type.build_value!(@const_int, nil) == @const_int
    end

    test "extract_value returns the value" do
      assert XDR.Type.extract_value!(@const_int) == 123
    end

    test "encode doesn't work" do
      assert_raise(XDR.Error, fn -> XDR.Type.encode!(@const_int) end)
    end

    test "decode doesn't work" do
      assert_raise(XDR.Error, fn -> XDR.Type.decode!(@const_int, "123") end)
    end
  end
end
