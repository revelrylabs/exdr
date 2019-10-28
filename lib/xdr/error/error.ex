defmodule XDR.Error do
  @typedoc """
  A single piece of a path, which will be either an atom or a binary
  """
  @type path_segment() :: binary() | atom()

  @typedoc """
  The "cursor" in the current path, which is usually just one segment,
  but may be a list. For example, if an error happens while resolving the
  type of an arm in a union, the current path_descriptor will be [:arm_key, :arms]
  so that the resulting error path after bubbling up might be e.g. "account.arms.user_account"
  """
  @type path_descriptor() :: path_segment() | list(path_segment())

  @moduledoc """
  Errors explicitly created by XDR will usually be an `XDR.Error`.
  Also, errors triggered inside a complex data type will be wrapped
  and annotated with path info before being re-raised or returned to the user.
  """
  defexception [:data, :message, :path, :type]

  @doc """
  Wrap an error (or anything really) into an `XDR.Error` so it can be
  annotated with XDR-specific metadata and bubbled up to the top level
  where it will be raised a final time or returned in an error tuple
  """
  def wrap(message) when is_binary(message), do: %XDR.Error{message: message}

  def wrap(message) when is_atom(message), do: %XDR.Error{message: message}

  def wrap(%XDR.Error{} = error), do: error

  def wrap({:error, error}), do: wrap(error)

  def wrap(%{message: message}), do: wrap(message)

  def wrap(error), do: %XDR.Error{message: "Unknown error", data: error}

  def wrap(error, []) do
    wrap(error)
  end

  def wrap(error, [head_segment | rest_segments]) do
    error
    |> wrap(head_segment)
    |> wrap(rest_segments)
  end

  def wrap(error, path_segment) do
    error
    |> wrap()
    |> prepend_path(path_segment)
  end

  @doc """
  Call a function and wrap any resulting error with the given path segment
  metadata. Used to make errors easier to trace back when working with types
  that have subsidiary child types
  """
  @spec wrap_call(atom(), list(), path_descriptor()) :: any()
  def wrap_call(function, args, current_path) do
    wrap_call(XDR, function, args, current_path)
  end

  @spec wrap_call(atom(), atom(), list(), path_descriptor()) :: any()
  def wrap_call(module, function, args, current_path)
      when is_atom(module) and is_atom(function) and is_list(args) do
    apply(module, function, args)
  rescue
    error -> reraise wrap(error, current_path), __STACKTRACE__
  end

  defp prepend_path(%XDR.Error{path: nil} = error, path_segment) do
    %{error | path: "#{path_segment}"}
  end

  defp prepend_path(error, path_segment) when is_atom(path_segment) do
    prepend_path(error, to_string(path_segment))
  end

  defp prepend_path(%XDR.Error{path: path} = error, path_segment) do
    %{error | path: "#{path_segment}.#{path}"}
  end
end
