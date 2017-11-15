# Compile a hash of settings for the gitlab module's `gitlab_rails` parameter, using SIMP settings
# @return Hash of settings for the 'gitlab::gitlab_rails' parameter
function simp_gitlab::omnibus_config::gitlab_rails() {

  $_servers = hash($simp_gitlab::ldap_uri.map |$server| {

    # We should also capture a port if it is specified at end of the URL, but
    # even simp_openldap doesn't support that.
    $_port = $server ? {
      /^(ldap):/  => '389',
      /^(ldaps):/ => '636',
      default     => fail("Cannot determine the LDAP port for '${server}'. Specify a complete URI" ),
    }

    if $simp_gitlab::ldap_encryption_method !~ Undef {
      $_method = $simp_gitlab::ldap_encryption_method
    }
    else {
      $_method = $server ? {
        /^(ldap):/  => 'start_tls',
        /^(ldaps):/ => 'simple_tls',
        default     => fail("Cannot determine the LDAP method for '${server}'. Specify a complete URI" ),
      }
    }


    [
      # can't use underscores: https://gitlab.com/gitlab-org/gitlab-ee/issues/1863
      regsubst($server, '\.|[-:/_]', '', 'G'),
      {
        ## label
        #
        # A human-friendly name for your LDAP server. It is OK to change the label later,
        # for instance if you find out it is too large to fit on the web page.
        #
        # Example: 'Paris' or 'Acme, Ltd.'
        'label'                         => 'LDAP',
        'host'                          => regsubst($server,'^ldaps?://',''),
        'port'                          => $_port,
        'uid'                           => 'uid',
        'method'                        => $_method,
        'bind_dn'                       => $simp_gitlab::ldap_bind_dn,
        'password'                      => $simp_gitlab::ldap_bind_pw,
        'ca_file'                       => $simp_gitlab::app_pki_ca,
        'active_directory'              => $simp_gitlab::ldap_active_directory,
        'allow_username_or_email_login' => false,
        'block_auto_created_users'      => false,
        'base'                          => $simp_gitlab::ldap_base_dn,
        'group_base'                    => pick_default($simp_gitlab::ldap_group_base,''),
        'user_filter'                   => pick_default($simp_gitlab::ldap_user_filter,''),
      }
    ]
  })


  if $::simp_gitlab::ldap {
    {
      'ldap_enabled' => true,
      'ldap_servers' => $_servers,
    }
  } else {
    {}
  }
}
