defmodule RinhaBackendWeb.TransactionController do
  use RinhaBackendWeb, :controller

  alias RinhaBackend.Services.TransactionService
  alias RinhaBackendWeb.Controllers.Transaction.TransactionRequest

  def create(conn, %{ "id" => id }) do
    with {id, _} <- Integer.parse(id),
         {:ok, params} <- TransactionRequest.validate(conn.params),
         true <- id >= 1 and id <= 5,
         {:ok, client} <- TransactionService.create_transaction(id, params) do
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(
        :ok,
        Jason.encode!(%{
          limite: client.limite,
          saldo: client.saldo
        })
      )
    else
      :error -> send_resp(conn, :not_found, "invalid id")
      {:error, :invalid_balance} -> send_resp(conn, :unprocessable_entity, "invalid balance")
      {:error, _changeset} -> send_resp(conn, :unprocessable_entity, "invalid payload")
      false -> send_resp(conn, :not_found, "not a customer")
    end
  end

  def get(conn, %{ "id" => id } = _params) do
    with {id, _} <- Integer.parse(id),
         true <- id >= 1 and id <= 5,
         data <- TransactionService.get_transactions(id) do
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(
        :ok,
        Jason.encode!(handle_response(data))
      )
    else
      :error -> send_resp(conn, :not_found, "invalid id")
      {:error, :invalid_balance} -> send_resp(conn, :unprocessable_entity, "invalid balance")
      {:error, _changeset} -> send_resp(conn, :unprocessable_entity, "invalid payload")
      false -> send_resp(conn, :not_found, "not a customer")
    end
  end

  defp handle_response(%{client: client, transactions: transactions}) do
    %{
      saldo: %{
        total: client.saldo,
        data_extrato: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second),
        limite: client.limite
      },
      ultimas_transacoes:
        Enum.map(transactions, fn transaction ->
          %{
            valor: transaction.valor,
            tipo: transaction.tipo,
            descricao: transaction.descricao,
            realizada_em: transaction.realizada_em
          }
        end)
    }
  end
end
