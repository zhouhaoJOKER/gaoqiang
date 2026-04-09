
# All jobs
ActiveJob.jobs

# All failed jobs
ActiveJob.jobs.failed

# All pending jobs in some queue
ActiveJob.jobs.pending.where(queue_name: "some_queue")

# All failed jobs of a given class
ActiveJob.jobs.failed.where(job_class_name: "SomeJob")

# All pending jobs of a given class with limit and offset
ActiveJob.jobs.pending.where(job_class_name: "SomeJob").limit(10).offset(5)

# For adapters that support these statuses:
# All scheduled/in-progress/finished jobs of a given class
ActiveJob.jobs.scheduled.where(job_class_name: "SomeJob")
ActiveJob.jobs.in_progress.where(job_class_name: "SomeJob")
ActiveJob.jobs.finished.where(job_class_name: "SomeJob")

# For adapters that support filtering by worker:
# All jobs in progress being run by a given worker
ActiveJob.jobs.in_progress.where(worker_id: 42)

# Retry all the jobs (only possible for failed jobs)
ActiveJob.jobs.failed.retry_all

# Retry all the jobs of a given class (only possible for failed jobs)
ActiveJob.jobs.failed.where(job_class_name: "SomeJob").retry_all

# Discard all failed jobs
ActiveJob.jobs.failed.discard_all

# Discard all pending jobs of a given class
ActiveJob.jobs.pending.where(job_class_name: "SomeJob").discard_all
# Or all pending jobs in a given queue:
ActiveJob.jobs.pending.where(queue_name: "some-queue").discard_all