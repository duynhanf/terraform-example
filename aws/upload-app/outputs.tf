output "website_bucket_name" {
  description = "Name (id) of the bucket"
  value       = module.website_s3_bucket.my_bucket_name
}
