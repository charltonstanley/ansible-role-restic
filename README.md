# Ansible role for restic

## Description

The restic role automatically installs the [`restic`](https://restic.readthedocs.io/en/stable) application and configures a systemd service with a systemd timer to allow backups to run on a schedule.

Role tasks:

* download and install `restic`
* create a service acccount and primary group
* create a systemd service and systemd timer
* create any required directories
* add directories to exclude by default from backups (i.e. `/proc`, `/dev`, etc.)
* specify a list of directories to include by default

## Role Variables

### restic_package_name

Name of the restic package for your distro.

**Type**: string

**Default**: `restic`

### restic_service_account_name

Service account name that will be used to run the restic service.

**Type**: string

**Default**: `svc-restic`

### restic_service_account_group

Primary group of the service account that will be used to run the restic service.

**Type**: string

**Default**: `svc-restic`

### systemd_timer_schedule

The desired systemd timer schedule. See <https://silentlad.com/systemd-timers-oncalendar-(cron)-format-explained> for a quick explanation with examples.

**Type**: string

**Default**: `*-*-* 0:00:00` (midnight every night)

### restic_service_account_home

The desired home directory for the service account that will be used to run the restic service.

**Type**: string

**Default**: `/home/{{ restic_service_account_name }}`

### systemd_instance_name

The name of the desired systemd service instance name for restic. For example, `restic@work.service` where `work` is the instance name, which would backup all the files and folders used for my job. The default is to backup the whole system; see `includes.files`.

**Type**: string

**Default**: `whole-system-backup`

### restic_key_id

The key id of the password to access the restic vault. See <https://restic.readthedocs.io/en/stable/070_encryption.html> for more details.

**Type**: string

**Default**: `null`

### restic_repo_path

The full path to the repo on the remote server. For example, `/home/username/backups/project`.

**Type**: string

**Default**: `null`

### ssh_username

Username used to connect to the remote server via SSH where the restic repo is stored.

**Type**: string

**Default**: `null`

### ssh_server_fqdn

FQDN of the remote server where the restic repo is stored.

**Type**: string

**Default**: `null`

## Usage

### Install Restic and Start the Systemd Timer

```yaml
# playbook/group_vars/all.yml
restic_key_id: 5c657874
restic_repo_path: /home/{{ ssh_username }}/backups/project
ssh_username: admin
ssh_server_fqdn: server.host.xlocal

# playbook/site.yml
- hosts: all
  roles:
    - { role: restic, tags: restic, become: true}
```

## Additional Miscellaneous Info

### SSH/SFTP Requirements

1. An SSH private is required to allow you to connect to `ssh_server_fqdn`. Place it in `{{ restic_service_account_home }}/.ssh/`.
2. Make sure the permissions are correct on the private key.
3. You will need to add a `known_hosts` file to `{{ restic_service_account_home }}/.ssh/` in order to trust the remote server's host key.

### Restic repo password

The password for your repo needs to be saved to `{{ restic_service_account_home }}/{{ systemd_instance_name }}/{{ restic_key_id }}`. This file was created automatically with the correct permissions and just needs to edited with the repo password that matches the specified key id.
