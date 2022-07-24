resource "aws_cognito_user_pool" "user_pool" {
  name = "user-pool-example-${terraform.workspace}"
  # ユーザー確認を行う際にEmail or 電話で自動検証を行うための設定。Emailを指定。
  auto_verified_attributes = [
    "email",
  ]

  # 検証するときのメッセージテンプレート。verification_message_templateが推奨のため、そちらで設定する。
  # email_verification_message = " 検証コードは {####} です。"
  # email_verification_subject = " 検証コード"
  # sms_verification_message   = " 検証コードは {####} です。"

  sms_authentication_message = " 認証コードは {####} です。"

  # 今回はMFAを使用しないためOFF。
  mfa_configuration = "OFF"

  admin_create_user_config {
    # ユーザーに自己サインアップを許可する。
    allow_admin_create_user_only = false

    # temporary_password_validity_daysと競合するため、そちらで設定する。
    # 管理者が設定した一時パスワードの有効期間。
    # unused_account_validity_days = 7

    invite_message_template {
      email_message = " ユーザー名は {username}、仮パスワードは {####} です。"
      email_subject = " 仮パスワード"
      sms_message   = " ユーザー名は {username}、仮パスワードは {####} です。"
    }
  }

  email_configuration {
    # https://docs.aws.amazon.com/ja_jp/cognito/latest/developerguide/user-pool-email.html
    # ユーザー招待時などに使用するメールの設定。Cognito(デフォルト) or SES が使用できる。
    # デフォルトだと送信数などに制限があるため、本番で使用する場合は、SESを使用した方がよい。
    email_sending_account = "COGNITO_DEFAULT"
  }

  # 登録するユーザーのパスワードポリシー。
  password_policy {
    minimum_length                   = 8
    require_lowercase                = true # 英小文字
    require_numbers                  = true # 数字
    require_symbols                  = true # 記号
    require_uppercase                = true # 英大文字
    temporary_password_validity_days = 7    # 初期登録時の一時的なパスワードの有効期限
  }

  # 「schema」は登録するユーザーに求める属性。(メールアドレスや電話番号など)
  # 「email」はデフォルトで有効になっている属性だが、今回は登録時に必須にしたいため設定。
  schema {
    attribute_data_type = "String"
    name                = "email"
    required            = true

    string_attribute_constraints {
      max_length = 256
      min_length = 1
    }
  }

  username_configuration {
    # ユーザー名(Email)で大文字小文字を区別しない。
    case_sensitive = false
  }

  # ユーザー登録時の招待メッセージの内容。
  verification_message_template {
    # 検証にはトークンではなく、リンクを使用する。
    default_email_option  = "CONFIRM_WITH_LINK"
    email_message         = " 検証コードは {####} です。"
    email_message_by_link = " E メールアドレスを検証するには、次のリンクをクリックしてください。{##Verify Email##} "
    email_subject         = " 検証コード"
    email_subject_by_link = " 検証リンク"
    sms_message           = " 検証コードは {####} です。"
  }

  tags = {
    Env = "dev"
  }
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  # OAuthを今回しようしないため設定しない。
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["email", "openid"]
  callback_urls                        = ["https://github.com/murayama-molo/terraform-aurora-sample"] // example

  explicit_auth_flows = [
    # 更新トークン(新しいアクセストークンを取得するのに必要。)
    "ALLOW_REFRESH_TOKEN_AUTH",
    # SRPプロトコルを使用してユーザー名&パスワードを検証する。
    "ALLOW_USER_SRP_AUTH",
  ]
  logout_urls                   = []
  name                          = aws_cognito_user_pool.user_pool.name
  prevent_user_existence_errors = "ENABLED"

  # 属性の読み取り有無設定。
  read_attributes = [
    "address",
    "birthdate",
    "email",
    "email_verified",
    "family_name",
    "gender",
    "given_name",
    "locale",
    "middle_name",
    "name",
    "nickname",
    "phone_number",
    "phone_number_verified",
    "picture",
    "preferred_username",
    "profile",
    "updated_at",
    "website",
    "zoneinfo",
  ]
  # 更新トークンの期限
  refresh_token_validity       = 30
  supported_identity_providers = ["COGNITO"]

  user_pool_id = aws_cognito_user_pool.user_pool.id

  # 属性の書き有無設定。
  write_attributes = [
    "address",
    "birthdate",
    "email",
    "family_name",
    "gender",
    "given_name",
    "locale",
    "middle_name",
    "name",
    "nickname",
    "phone_number",
    "picture",
    "preferred_username",
    "profile",
    "updated_at",
    "website",
    "zoneinfo",
  ]
}

resource "aws_cognito_identity_pool" "identity_pool" {
  identity_pool_name = "identity-pool-example-${terraform.workspace}"

  # 認証していないユーザーには使用させないため、falseを設定。
  allow_unauthenticated_identities = false

  openid_connect_provider_arns = []
  saml_provider_arns           = []
  supported_login_providers    = {}
  tags                         = {}

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.user_pool_client.id
    provider_name           = "cognito-idp.ap-northeast-1.amazonaws.com/${aws_cognito_user_pool.user_pool.id}"
    server_side_token_check = false
  }
}

resource "aws_cognito_user_pool_domain" "user_pool_domain" {
  domain       = "user-pool-example-domain-${terraform.workspace}"
  user_pool_id = aws_cognito_user_pool.user_pool.id
}

output "aws_cognito_user_pool_id" {
  value = aws_cognito_user_pool.user_pool.id
}

output "aws_cognito_user_pool_client_id" {
  value = aws_cognito_user_pool_client.user_pool_client.id
}

output "aws_cognito_user_pool_domain" {
  value = aws_cognito_user_pool_domain.user_pool_domain.domain
}
