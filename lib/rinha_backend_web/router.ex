defmodule RinhaBackendWeb.Router do
  use RinhaBackendWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RinhaBackendWeb do
    pipe_through :api

    post "/clientes/:id/transacoes", TransactionController, :create
    get "/clientes/:id/extrato", TransactionController, :get
  end


end
