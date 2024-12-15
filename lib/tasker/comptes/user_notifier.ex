defmodule Tasker.Comptes.UserNotifier do
  import Swoosh.Email

  alias Tasker.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Tasker", "contact@example.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    deliver(user.email, "Instruction de confirmation", """

    ==============================

    Bonjour #{user.email},

    Vous pouvez confirmer votre compte en visitant le lien ci-dessous :

    #{url}

    Si vous n'êtes pas à l'origine de la création de ce compte, merci d'ignorer ce message.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    deliver(user.email, "Instruction de réinitialisation de mot de passe", """

    ==============================

    Bonjour #{user.email},

    Vous pouvez réinitialiser votre mot de passe en visitant le lien ci-dessous :

    #{url}

    Si vous n'êtes pas à l'origine de cette demande, merci d'ignorer ce message.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Instructions d'actualisation du mèl", """

    ==============================

    Bonjour #{user.email},

    Vous pouvez changer votre mèl en visitant le lien ci-dessous :

    #{url}

    Si vous n'êtes pas à l'origine de cette demande, merci d'ignorer ce message.

    ==============================
    """)
  end
end
