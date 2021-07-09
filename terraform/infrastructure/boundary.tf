resource "nomad_job" "boundary" {
  hcl2 {
    enabled = true
  }

  jobspec = file("${path.module}/jobs/boundary.nomad")
}
