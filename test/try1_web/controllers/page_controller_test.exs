defmodule TaskerWeb.PageControllerTest do
  use TaskerWeb.ConnCase

  @moduletag :mine

  # Test de la page d'accueil
  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    response = html_response(conn, 200)
    assert response =~ "TASKER"
    assert response =~ "Liste des tâches"
  end
end
