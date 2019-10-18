defmodule XDR.ErrorTest do
  use ExUnit.Case
  alias XDR.Error
  @message "Something bad happened"

  defmodule ErrorXDR do
    use XDR.Base
    define_type("name", XDR.Type.VariableOpaque)
    define_type("short_acct_id", XDR.Type.Opaque, 8)
    define_type("long_acct_id", XDR.Type.Opaque, 16)
    define_type("five_names", XDR.Type.Array, type: "name", length: 5)
    define_type("some_names", XDR.Type.VariableArray, type: "name")

    define_type(
      "account_id",
      Union,
      switch_name: :type,
      switch_type: XDR.build_type(XDR.Type.Int),
      switches: [
        {-1, XDR.Type.Void},
        {0, :short},
        {1, :long}
      ],
      arms: [
        short: "short_acct_id",
        long: "long_acct_id"
      ]
    )

    define_type(
      "struct_with_names",
      XDR.Type.Struct,
      five_names: "five_names",
      some_names: "some_names",
      account_id: "account_id"
    )
  end

  describe "Nested, wrapped errors" do
    test "fixed array error on build_value" do
      assert {:error, error} =
               ErrorXDR.build_value(
                 "struct_with_names",
                 five_names: ["Marvin", "Arthur", "Trillian", 123, "Zaphod"],
                 some_names: ["Marvin"],
                 account_id: -1
               )

      assert error.path == "five_names.3"
      assert error.data == 123
      assert error.type == "name"
    end

    test "variable array error on build_value" do
      assert {:error, error} =
               ErrorXDR.build_value(
                 "struct_with_names",
                 five_names: ["Marvin", "Arthur", "Trillian", "Ford", "Zaphod"],
                 some_names: ["Marvin", :nobody],
                 account_id: -1
               )

      assert error.path == "some_names.1"
      assert error.data == :nobody
      assert error.type == "name"
    end

    test "union error on switch" do
      assert {:error, error} =
               ErrorXDR.build_value(
                 "struct_with_names",
                 five_names: ["Marvin", "Arthur", "Trillian", "Ford", "Zaphod"],
                 some_names: ["Marvin"],
                 account_id: {"abc", "123456"}
               )

      assert error.path == "account_id.switch_value"
      assert error.data == "abc"
    end

    test "union error on main value" do
      assert {:error, error} =
               ErrorXDR.build_value(
                 "struct_with_names",
                 five_names: ["Marvin", "Arthur", "Trillian", "Ford", "Zaphod"],
                 some_names: ["Marvin"],
                 account_id: {1, "123456"}
               )

      assert error.path == "account_id"
      assert error.data == "123456"
    end

    test "variable array error on decode" do
      #            arr length: 2     str length: 2             str length: 2... should be more
      bad_encoding = <<0, 0, 0, 2>> <> <<0, 0, 0, 2>> <> "ab" <> <<0, 0, 0, 2>>
      assert {:error, error} = ErrorXDR.decode("some_names", bad_encoding)

      assert "#{error.path}" == "1"
    end
  end

  describe "Additional wrappers" do
    test "wraps a plain string message" do
      message = @message
      assert %Error{message: ^message} = Error.wrap(message)
    end

    test "wraps an error tuple with a string" do
      message = @message
      assert %Error{message: ^message} = Error.wrap({:error, message})
    end

    test "wraps an error tuple with an atom" do
      message = :error_thing
      assert %Error{message: ^message} = Error.wrap({:error, message})
    end

    test "wraps a map with a message key" do
      message = @message
      assert %Error{message: ^message} = Error.wrap(%{message: message})
    end

    test "wraps a totally unknown thing" do
      error = [1, 2, 3, :error]
      assert %Error{data: ^error} = Error.wrap(error)
    end
  end
end
