defmodule XDR.ErrorTest do
  use ExUnit.Case
  alias XDR.Error
  @message "Something bad happened"

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
