// This will fail on 1st deployment due to ZIP not being present in GCS
resource "google_cloudfunctions_function" "node-worker-function" {
  name                  = "${var.feature_name}-function"
  runtime               = "nodejs14"
  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.node-worker-bucket.name
  source_archive_object = google_storage_bucket_object.node-worker-code.name

  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.node-worker-topic.name
  }

  entry_point = "subscribe"

  labels = {
    feature = var.feature_name
  }
}
