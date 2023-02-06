output "nginx_documents" {
  value = data.kubectl_path_documents.nginx.documents
}