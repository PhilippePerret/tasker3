defmodule TaskerWeb.UserRegistrationLive do
  use TaskerWeb, :live_view

  alias Tasker.Comptes
  alias Tasker.Comptes.User

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Créer un compte
        <:subtitle>
          Déjà enregistré ?
          <.link navigate={~p"/users/log_in"} class="font-semibold text-brand hover:underline">
            S’identifier
          </.link>
          maintenant.
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/users/log_in?_action=registered"}
        method="post"
      >
        <.error :if={@check_errors}>
          Oops, quelque chose a mal tourné… Merci de vérifier les erreurs ci-dessous.
        </.error>

        <.input field={@form[:email]} type="email" label="Mèl" required />
        <.input field={@form[:password]} type="password" label="Mot de passe" required />

        <:actions>
          <.button phx-disable-with="Création du compte..." class="w-full">Créer le compte</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Comptes.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Comptes.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Comptes.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Comptes.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Comptes.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
