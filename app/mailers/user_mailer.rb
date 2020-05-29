class UserMailer < ApplicationMailer
  def account_activation user
    @user = user
    mail to: user.email, subject: t("text_label_activate")
  end

  def password_reset user
    @user = user
    mail to: user.email, subject: t("text_password_reset")
  end
end
