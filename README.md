# Echo Client
> Distributed Systems

#### Run The PHP Echo Server
`php -S 127.0.0.1:8000 -t .`



#### Build Client
`mix escript.build`

#### Run Client
`./echo --host "localhost" --port "8000" --path "/echo.php" --message "hello world"`
