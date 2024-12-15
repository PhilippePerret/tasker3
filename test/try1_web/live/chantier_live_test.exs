defmodule TaskerWeb.ChantierLiveTest do
  use TaskerWeb.ConnCase

  import Phoenix.LiveViewTest
  import Tasker.TachesFixtures

  @create_attrs %{name: "some name", description: "some description", started_at: "2024-11-14T14:36:00", ended_at: "2024-11-14T14:36:00"}
  @update_attrs %{name: "some updated name", description: "some updated description", started_at: "2024-11-15T14:36:00", ended_at: "2024-11-15T14:36:00"}
  @invalid_attrs %{name: nil, description: nil, started_at: nil, ended_at: nil}

  defp create_chantier(_) do
    chantier = chantier_fixture()
    %{chantier: chantier}
  end

  describe "Index" do
    setup [:create_chantier]

    test "lists all chantiers", %{conn: conn, chantier: chantier} do
      {:ok, _index_live, html} = live(conn, ~p"/chantiers")

      assert html =~ "Listing Chantiers"
      assert html =~ chantier.name
    end

    test "saves new chantier", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/chantiers")

      assert index_live |> element("a", "New Chantier") |> render_click() =~
               "New Chantier"

      assert_patch(index_live, ~p"/chantiers/new")

      assert index_live
             |> form("#chantier-form", chantier: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#chantier-form", chantier: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/chantiers")

      html = render(index_live)
      assert html =~ "Chantier created successfully"
      assert html =~ "some name"
    end

    test "updates chantier in listing", %{conn: conn, chantier: chantier} do
      {:ok, index_live, _html} = live(conn, ~p"/chantiers")

      assert index_live |> element("#chantiers-#{chantier.id} a", "Edit") |> render_click() =~
               "Edit Chantier"

      assert_patch(index_live, ~p"/chantiers/#{chantier}/edit")

      assert index_live
             |> form("#chantier-form", chantier: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#chantier-form", chantier: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/chantiers")

      html = render(index_live)
      assert html =~ "Chantier updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes chantier in listing", %{conn: conn, chantier: chantier} do
      {:ok, index_live, _html} = live(conn, ~p"/chantiers")

      assert index_live |> element("#chantiers-#{chantier.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#chantiers-#{chantier.id}")
    end
  end

  describe "Show" do
    setup [:create_chantier]

    test "displays chantier", %{conn: conn, chantier: chantier} do
      {:ok, _show_live, html} = live(conn, ~p"/chantiers/#{chantier}")

      assert html =~ "Show Chantier"
      assert html =~ chantier.name
    end

    test "updates chantier within modal", %{conn: conn, chantier: chantier} do
      {:ok, show_live, _html} = live(conn, ~p"/chantiers/#{chantier}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Chantier"

      assert_patch(show_live, ~p"/chantiers/#{chantier}/show/edit")

      assert show_live
             |> form("#chantier-form", chantier: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#chantier-form", chantier: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/chantiers/#{chantier}")

      html = render(show_live)
      assert html =~ "Chantier updated successfully"
      assert html =~ "some updated name"
    end
  end
end
