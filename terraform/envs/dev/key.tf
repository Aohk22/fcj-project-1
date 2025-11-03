resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKkAX0+yqK1s2jAhDy+uTrhFH5VZ59/eqHhlPhlhxYeU tkl@tkl-pc"
}
