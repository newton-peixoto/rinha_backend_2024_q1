defmodule RinhaBackend.Services.TransactionService do
  alias RinhaBackend.TransactionSchema
  alias RinhaBackend.ClientSchema
  alias RinhaBackend.Repo
  import Ecto.Query

  def create_transaction(id, params) do
    Repo.transaction(fn ->
      try do
        Repo.insert(%TransactionSchema{
          tipo: params.tipo,
          descricao: params.descricao,
          valor: params.valor,
          cliente_id: id
        })
      rescue
        Postgrex.Error -> Repo.rollback(:invalid_balance)
      end

      client =
        %ClientSchema{} =
        ClientSchema |> where([u], u.id == ^id) |> Repo.one()

      client
    end)
  end

  def get_transactions(id) do
    client = %ClientSchema{} = Repo.get(ClientSchema, id)

    query =
      from t in TransactionSchema,
        where: t.cliente_id == ^id,
        order_by: [desc: :realizada_em],
        limit: 10

    transactions = Repo.all(query)

    %{client: client, transactions: transactions}
  end
end
