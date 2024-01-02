###################
# EKS
###################
module "helm" {
  source                                  = "../../modules/helm"
  eks_cluster_name                        = data.terraform_remote_state.network.outputs.eks_cluster_name
  aws_region                              = local.aws_region
  alb_ingress_controller_chart_name       = "aws-load-balancer-controller"
  alb_ingress_controller_chart_repo       = "https://aws.github.io/eks-charts"
  alb_ingress_controller_chart_version    = "1.6.0"
  alb_ingress_controller_chart_namespace  = "kube-system"
  environment                             = local.environment
  service                                 = local.service
  external_alb_ssl_cert                   = "arn:aws:acm:ap-southeast-1:511635964514:certificate/32d5c63f-c780-4d28-b29e-716af5abb043"
  external_alb_host                       = "*.dev.xrspace.io"
  developer_kms_policy_arn                = data.terraform_remote_state.iam.outputs.developer_kms_policy_arn
  github_oauth_argocd_secret_arn          = "arn:aws:secretsmanager:ap-southeast-1:047401700492:secret:github-oauth-argo-YhWo3C"
  argocd_chart_name                       = "argo-cd"
  argocd_chart_repo                       = "https://argoproj.github.io/argo-helm"
  argocd_chart_version                    = "5.43.4"
  argocd_chart_namespace                  = "kube-system"
  argocd_image_updater_chart_name         = "argocd-image-updater"
  argocd_image_updater_chart_version      = "0.9.1"
  account_id                              = data.aws_caller_identity.current.account_id
  helm_secret_version                     = "4.5.0"
  vals_version                            = "0.24.0"
  sops_version                            = "3.7.3"
  kubectl_version                         = "1.28.0"
  argocd_host                             = "argocd.dev.xrspace.io"
  github_oauth_grafana_secret_arn         = "arn:aws:secretsmanager:ap-southeast-1:047401700492:secret:github-oauth-grafana-iWenPI"
  grafana_chart_name                      = "grafana"
  grafana_chart_repo                      = "https://grafana.github.io/helm-charts"
  grafana_chart_version                   = "6.59.1"
  grafana_chart_namespace                 = "monitoring"
  grafana_host                            = "grafana.dev.xrspace.io"
  promtail_chart_name                     = "promtail"
  promtail_chart_repo                     = "https://grafana.github.io/helm-charts"
  promtail_chart_version                  = "6.15.3"
  promtail_chart_namespace                = "kube-system"
  loki_chart_name                         = "loki"
  loki_chart_repo                         = "https://grafana.github.io/helm-charts"
  loki_chart_version                      = "5.20.0"
  loki_chart_namespace                    = "monitoring"
  tempo_chart_name                        = "tempo-distributed"
  tempo_chart_repo                        = "https://grafana.github.io/helm-charts"
  tempo_chart_version                     = "1.6.2"
  tempo_chart_namespace                   = "monitoring"
  opentelemetry_collector_chart_name      = "opentelemetry-collector"
  opentelemetry_collector_chart_repo      = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  opentelemetry_collector_chart_version   = "0.68.0"
  opentelemetry_collector_chart_namespace = "monitoring"
  dagster_chart_name                      = "dagster"
  dagster_chart_repo                      = "https://dagster-io.github.io/helm"
  dagster_chart_version                   = "1.5.9"
  dagster_chart_namespace                 = "dagster"
  dagster_host                            = "dagster.dev.xrspace.io"
  github_oauth_dagster_secret_arn         = "arn:aws:secretsmanager:ap-southeast-1:047401700492:secret:github-oauth-dagster-mgbFpc"
  oauth2_proxy_chart_name                 = "oauth2-proxy"
  oauth2_proxy_chart_repo                 = "https://oauth2-proxy.github.io/manifests"
  oauth2_proxy_chart_version              = "6.19.1"
  oauth2_proxy_chart_namespace            = "oauth2-proxy"
  oauth2_proxy_host                       = "oauth2-proxy.dev.xrspace.io"
  postgres_address                        = data.terraform_remote_state.storage.outputs.postgres_address
  postgres_port                           = data.terraform_remote_state.storage.outputs.postgres_port
  postgres_db_name                        = "xrspace"
  postgres_username                       = local.postgres_user_creds.username
  postgres_password                       = local.postgres_user_creds.password
  postgres_engine_version                 = "15.5"
}

module "namespace" {
  source     = "../../modules/namespace"
  namespaces = ["one-app-develop"]
}

module "sa" {
  source             = "../../modules/sa"
  eks_oidc_url       = module.eks.oidc_provider
  eks_oidc_arn       = module.eks.oidc_provider_arn
  eks_cluster_name   = data.terraform_remote_state.network.outputs.eks_cluster_name
  s3_bucket_name     = data.terraform_remote_state.storage.outputs.s3_backend_bucket_name
  s3_tmp_bucket_name = data.terraform_remote_state.storage.outputs.s3_backend_tmp_bucket_name
  s3_cms_bucket_name = data.terraform_remote_state.storage.outputs.s3_cms_bucket_name
  namespaces         = ["one-app-develop"]
}
