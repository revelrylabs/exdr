defmodule XDR.Error do
  @moduledoc """
  Errors explicitly created by XDR will usually be an `XDR.Error`.
  Also, errors triggered inside a complex data type will be wrapped
  and annotated with path info before being re-raised or returned to the user.
  """
  defexception [:data, :message, :path, :type]
  def wrap(message) when is_binary(message), do: %XDR.Error{message: message}

  def wrap(message) when is_atom(message), do: %XDR.Error{message: message}

  def wrap(%XDR.Error{} = error), do: error

  def wrap({:error, error}), do: wrap(error)

  def wrap(%{message: message}), do: wrap(message)

  def wrap(error), do: %XDR.Error{message: "Unknown error", data: error}

  def wrap(error, path_segment) do
    prepend_path(wrap(error), path_segment)
  end

  @doc """
  Call a function and wrap any resulting error with the given path segment
  metadata. Used to make errors easier to trace back when working with types
  that have subsidiary child types
  """
  @spec wrap_call(atom(), list(), atom() | binary()) :: any()
  def wrap_call(function, args, path_segment) do
    wrap_call(XDR, function, args, path_segment)
  end

  @spec wrap_call(atom(), atom(), list(), atom() | binary()) :: any()
  def wrap_call(module, function, args, path_segment)
      when is_atom(module) and is_atom(function) and is_list(args) do
    apply(module, function, args)
  rescue
    error -> reraise wrap(error, path_segment), __STACKTRACE__
  end

  defp prepend_path(%XDR.Error{path: nil} = error, path_segment) do
    %{error | path: path_segment}
  end

  defp prepend_path(error, path_segment) when is_atom(path_segment) do
    prepend_path(error, to_string(path_segment))
  end

  defp prepend_path(%XDR.Error{path: path} = error, path_segment) do
    %{error | path: "#{path_segment}.#{path}"}
  end
end
