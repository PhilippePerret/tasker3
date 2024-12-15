defmodule TaskerWeb.UsersController do
  use TaskerWeb, :controller

  alias Tasker.Comptes

  def liste(conn, _params) do
    render(conn, :liste)
  end

  def show(conn, %{"id" => user_id}) do
    _user = Comptes.get_user!(user_id)
    render(conn, :show)
  end

end