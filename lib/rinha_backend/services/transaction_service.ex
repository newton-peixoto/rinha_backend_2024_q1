defmodule RinhaBackend.Services.TransactionService do
  alias RinhaBackend.TransactionSchema
  alias RinhaBackend.ClientSchema
  alias RinhaBackend.Repo
  import Ecto.Query

  def create_transaction(id, params) do
    Repo.transaction(fn ->
      client = %ClientSchema{} =
        ClientSchema |> where([u], u.id == ^id) |> lock("FOR UPDATE") |> Repo.one()

      new_balance =
        cond do
          params.tipo == :d and client.saldo - params.valor < client.limite * -1 ->
            Repo.rollback(:invalid_balance)

          params.tipo == :d ->
            client.saldo - params.valor

          params.tipo == :c ->
            client.saldo + params.valor
        end

      {:ok, _transaction} =
          Repo.insert(%TransactionSchema{
            tipo:  params.tipo,
            descricao: params.descricao,
            valor: params.valor,
            cliente_id: client.id,
          })

      client = Ecto.Changeset.change(client, saldo: new_balance)

      {:ok, client} = Repo.update(client)

       client
    end)
  end


  def get_transactions(id) do
    client = %ClientSchema{} = Repo.get(ClientSchema, id)

    query = from t in TransactionSchema,
              where: t.cliente_id == ^id,
              order_by: [desc: :realizada_em],
              limit: 10

    transactions = Repo.all(query)

    %{client: client, transactions: transactions }
  end
end
