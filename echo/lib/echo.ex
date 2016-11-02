# Author: Ciaran Finn
# Date: 24/10/2016

defmodule Echo do

  def main(args) do
    args |> get_args |> open_socket
  end

  defp get_args(args) do
    {arguments,_,_} = OptionParser.parse(args,
      switches: [host: :string, port: :string, path: :string, message: :string]
    )
    case arguments do
      [{:host, _},{:port, _},{:path, _},{:message, _}] ->
        arguments
      _ ->
        IO.puts "Example Format: --host 'localhost' --port '8000' --path '/echo.php?message=' --message 'hello'"
        System.halt(0)
    end
  end

  defp open_socket(arguments) do
    host = String.to_char_list(arguments[:host])
    port = arguments[:port]

    case Integer.parse(port) do
      {port, _ } ->
         establish_connection(arguments,port,host)
      :error ->
        IO.puts "There was an issue with the port you provided"
    end
  end

  defp establish_connection(arguments,port,host) do
    options = [:binary, {:active, false}]
    case :gen_tcp.connect(host, port, options) do
      {:ok, socket} ->
        send_data(socket,arguments)
      {:error, reason} ->
        IO.puts "TCP connection error: #{reason}"
    end
  end

  defp send_data(socket,arguments) do
    path = arguments[:path]
    
    # Ensure text is transmited in URL string
    message = URI.encode_www_form(arguments[:message])
    request = "GET #{path}#{message} HTTP/1.0\r\n\r\n"

    case :gen_tcp.send(socket, request) do
      :ok ->
        receive_data(socket)
      {:error, reason} ->
        IO.puts "Error sending data: #{reason}"
    end
  end

  defp receive_data(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, packet} ->
        IO.puts packet
      {:error, reason} ->
        IO.puts "Error receiving data: #{reason}"
    end
    :gen_tcp.close socket
  end

end
