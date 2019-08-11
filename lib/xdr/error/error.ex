defmodule XDR.Error do
  defexception [:data, :message, :path, :type]
  def wrap(message) when is_binary(message), do: %XDR.Error{message: message}

  def wrap(%XDR.Error{} = error), do: error

  def wrap({:error, error}), do: wrap(error)

  def wrap(%{message: message}), do: wrap(message)

  def wrap(error), do: %XDR.Error{message: "Unknown error", data: error}

  def wrap(error, path_segment) do
    prepend_path(wrap(error), path_segment)
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
