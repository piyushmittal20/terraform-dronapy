# resource "random_password" "password" {
#   length           = 24
#   special          = true
#   min_special      = 5
#   override_special = "!#$%^&*()-_=+[]{}<>:?"
# }


# resource "aws_secretsmanager_secret" "staging-db-pass" {
#   name = "db-pass-test-service"

#   recovery_window_in_days = 0 #
# }

# resource "aws_secretsmanager_secret_version" "db-pass-drona-service-val" {
#   secret_id     = aws_secretsmanager_secret.staging-db-pass.id
#   secret_string = random_password.password.result
# }
