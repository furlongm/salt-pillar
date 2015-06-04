class postfix(
  $root_alias='admin@example.com'
) {

  package { 'postfix':
    ensure => installed,
  }

  $mailx = $::osfamily ? {
    'Debian' => 'bsd-mailx',
    default  => 'mailx',
  }

  package { $mailx:
    ensure => installed,
  }

  service { 'postfix':
    ensure  => running,
    enable  => true,
    require => Package['postfix'],
  }

  file { '/etc/postfix/main.cf':
    content => template('postfix/main.cf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['postfix'],
    notify  => Service['postfix'],
  }

  mailalias { 'root_alias':
    ensure    => present,
    name      => 'root',
    recipient => $root_alias,
    target    => '/etc/aliases'
  }

  exec { 'newaliases':
    command     => '/usr/bin/newaliases',
    refreshonly => true,
    subscribe   => Mailalias['root_alias'],
    notify      => Service['postfix'],
  }
}
