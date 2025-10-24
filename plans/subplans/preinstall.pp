# @summary Prepare target nodes for PE installation
#
# Installs required packages, and configuration required before PE can be installed.
plan peadm::subplans::preinstall (
  # Standard
  Peadm::SingleTargetSpec           $primary_host,
  Optional[Peadm::SingleTargetSpec] $replica_host = undef,

  # Large
  Optional[TargetSpec]              $compiler_hosts = undef,
  Optional[TargetSpec]              $legacy_compilers = undef,

  # Extra Large
  Optional[Peadm::SingleTargetSpec] $primary_postgresql_host = undef,
  Optional[Peadm::SingleTargetSpec] $replica_postgresql_host = undef,
) {
  # Convert inputs into targets.
  $primary_target            = peadm::get_targets($primary_host, 1)
  $replica_target            = peadm::get_targets($replica_host, 1)
  $primary_postgresql_target = peadm::get_targets($primary_postgresql_host, 1)
  $replica_postgresql_target = peadm::get_targets($replica_postgresql_host, 1)
  $compiler_targets          = peadm::get_targets($compiler_hosts)
  $legacy_compiler_targets   = peadm::get_targets($legacy_compilers)

  $all_targets = peadm::flatten_compact([
      $primary_target,
      $primary_postgresql_target,
      $replica_target,
      $replica_postgresql_target,
      $compiler_targets,
      $legacy_compiler_targets,
  ])

  apply($all_targets) {
    # Required for pulling PE packages
    package { 'curl':
      ensure => installed,
    }

    # Required for adding package GPG keys
    package { 'gnupg':
      ensure => installed,
    }
  }

  $all_targets.each |$target| {
    apply($target) {
      case facts($target)['os']['family'] {
        'RedHat', 'Amazon', 'AlmaLinux', 'CentOS', 'SLES': {
          package { 'glibc-langpack-en':
            ensure => installed,
          }
        }
        'Debian': {
          package { 'locales':
            ensure => installed,
          }
        }
        default: {
          # No-op for other OS families
        }
      }
    }
  }

  # Configure Locale to ensure en_US.UTF-8 is available.
  # Required by PuppetDB.
  run_command('locale-gen en_US.UTF-8', $all_targets)

  return('Pre-Installation succeeded.')
}
