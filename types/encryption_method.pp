# @see https://docs.gitlab.com/ce/administration/auth/ldap.html#configuration
type Simp_gitlab::Encryption_method = Enum[
  'plain',
  'start_tls',
  'simple_tls'
]
