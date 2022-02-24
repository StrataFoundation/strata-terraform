
// Legacy... Can't delete it without the dploy failing. Want to keep that data though.
resource "aws_s3_bucket" "blocks_bucket" {
  bucket = "${var.env}-wumbo-solana-blocks"
}

resource "aws_s3_bucket" "strata_blocks_bucket" {
  bucket = "${var.env}-strata-solana-blocks"
}
