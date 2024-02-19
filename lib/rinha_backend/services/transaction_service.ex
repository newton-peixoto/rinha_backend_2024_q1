defmodule RinhaBackend.Services.TransactionService do
  alias RinhaBackend.Repo


  def create_transaction(id, params) do
    %{
      rows: [
        [{saldo, had_problem, _, limite}] | _
      ]
    } =
      case params.tipo do
        :c -> Repo.query!("select creditar(#{id},#{params.valor},'#{params.descricao}')")
        :d -> Repo.query!("select debitar(#{id},#{params.valor},'#{params.descricao}')")
      end

    cond do
      had_problem == true -> {:error, :invalid_balance}
      true -> {:ok, %{limite: limite, saldo: saldo}}
    end
  end

  def get_transactions(id) do
    _ =
      %{
        rows: rows
      } =
      Repo.query!(
        "(select saldo, 'saldo' as tipo, 'saldo' as descricao, now() as realizada_em, limite
    from clientes
    where id = #{id})
    union all
    (select valor, tipo, descricao, realizada_em, 1 as limite
    from transacoes
    where cliente_id = #{id}
    order by id desc limit 10)"
      )

    [[saldo, _, _, _, limite] | transacoes] = rows

    cliente = %{saldo: saldo, limite: limite}

    transactions =
      Enum.map(transacoes, fn [valor, tipo, descricao, realizada_em, _] ->
        %{
          valor: valor,
          tipo: tipo,
          descricao: descricao,
          realizada_em: realizada_em
        }
      end)

    %{client: cliente, transactions: transactions}
  end
end
