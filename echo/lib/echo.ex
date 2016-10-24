# Author: Ciaran Finn
# Date: 24/10/2016

defmodule Echo do

  def main(args) do
    args |> get_args |> open_tcp
  end

  defp get_args(args) do
    {arguments,_,_} = OptionParser.parse(args,
      switches: [endpoint: :string, message: :string]
    )
    arguments
  end

  defp open_tcp(arguments) do
    [host,port] = Regex.split(~r/:/, arguments[:endpoint])
    host = String.to_char_list(host)

    case Integer.parse(port) do
      {port, _ } ->
         connection(arguments,port,host)
      :error ->
        IO.puts "There Was An Issue With The Port You Provided"
    end
  end

  defp connection(arguments,port,host) do

    options = [:binary, {:active, false}]
    case :gen_tcp.connect(host, port, options) do
      {:ok, socket} ->
        send_data(socket,arguments)
      {:error, _reason} ->
        IO.puts "TCP Connection Error: #{_reason}"
    end
  end

  defp send_data(socket,arguments) do
    message = URI.encode_www_form(arguments[:message])
    request = "GET /echo.php?message=#{message} HTTP/1.0\r\n\r\n"

    case :gen_tcp.send(socket, request) do
      :ok ->
        receive_data(socket)
      {:error, _reason} ->
        IO.puts "Error Sending Data: #{_reason}"
    end
  end

  defp receive_data(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, packet} ->
        IO.puts packet
      {:error, _reason} ->
        IO.puts "Error Receiving Data: #{_reason}"
    end

    :gen_tcp.close(socket)
  end

end
