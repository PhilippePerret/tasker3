defmodule TaskerWeb.UserConfirmationInstructionsLive do
  use TaskerWeb, :live_view

  alias Tasker.Comptes

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Pas d'instructions de confirmation reçues ?
        <:subtitle>Nous allons vous envoyer une nouvelle confirmation par mèl</:subtitle>
      </.header>

      <.simple_form for={@form} id="resend_confirmation_form" phx-submit="send_instructions">
        <.input field={@form[:email]} type="email" placeholder="Mèl" required />
        <:actions>
          <.button phx-disable-with="Envoi..." class="w-full">
            Renvoi des instructions de confirmation
          </.button>
        </:actions>
      </.simple_form>

      <p class="text-center mt-4">
        <.link href={~p"/users/register"}>S’inscrire</.link>
        | <.link href={~p"/users/log_in"}>S’identifier</.link>
      </p>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_instructions", %{"user" => %{"email" => email}}, socket) do
    if user = Comptes.get_user_by_email(email) do
      Comptes.deliver_user_confirmation_instructions(
        user,
        &url(~p"/users/confirm/#{&1}")
      )
    end

    info =
      "Si votre mèl est dans notre système mais n'a pas encore été confirmé, vous allez recevoir un message avec les instructions très prochainement."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
