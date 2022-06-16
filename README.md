# Ansible role for restic

## Description

The restic ansible role automatically installs the [`restic`](https://restic.readthedocs.io/en/stable) application and configures a systemd service with a systemd timer to allow backups to run on a schedule. Currently only sftp is supported, but this could probably easily be modified to accomodate other protocols.

Role tasks:

* download and install restic
* create a service acccount and primary group
* create a systemd service and systemd timer
* create any required directories
* specify a list to exclude by default from backups (i.e. `/proc`, `/dev`, etc.)
* specify a list of directories to ibackup
* start the systemd timer

## Role Variables

### restic_package_name

Name of the restic package for your distro.

**Type**: string

**Default**: `restic`

**Required**: true

### restic_service_account_name

Service account name that will be used to run the restic service.

**Type**: string

**Default**: `svc-restic`

**Required**: true

### restic_service_account_group

Primary group of the service account that will be used to run the restic service.

**Type**: string

**Default**: `svc-restic`

**Required**: true

### systemd_restic_timer_schedule

The desired systemd timer schedule. See <https://silentlad.com/systemd-timers-oncalendar-(cron)-format-explained> for a quick explanation with examples.

**Type**: string

**Default**: `*-*-* 0:00:00` (midnight every night)

**Required**: true

### restic_service_account_home

The desired home directory for the service account that will be used to run the restic service.

**Type**: string

**Default**: `/home/{{ restic_service_account_name }}`

**Required**: true

### systemd_instance_name

The name of the desired systemd service instance name for restic. For example, `restic@work.service` where `work` is the instance name, which would backup all the files and folders used for my job. The default is to backup the whole system; see `includes.files`.

**Type**: string

**Default**: `whole-system-backup`

**Required**: true

### restic_key_id

The key id of the password to access the restic vault. See <https://restic.readthedocs.io/en/stable/070_encryption.html> for more details.

**Type**: string

**Default**: `null`

**Required**: true

### restic_repo_path

The full path to the repo on the remote server. For example, `/home/username/backups/project`.

**Type**: string

**Default**: `null`

**Required**: true

### ssh_username

Username used to connect to the remote server via SSH where the restic repo is stored.

**Type**: string

**Default**: `null`

**Required**: true

### ssh_server_fqdn

FQDN of the remote server where the restic repo is stored.

**Type**: string

**Default**: `null`

**Required**: true

### exclude_list

List of file/folder paths that will be excluded from backup.

**Type**: list

**Default**:
  
  ```yaml
    - /dev
    - /proc
    - /sys
    - /tmp
    - /run
    - /mnt
    - /media
    - /lost+found
    - /swapfile
    - /cdrom
    - /root
  ```

**Required**: true

### include_list

List of file/folder paths that will be backed up.

**Type**: list

**Default**:
  
  ```yaml
    - /
  ```

**Required**: true

### enable_desktop_notifications

Enable desktop notifications for if/when the service fails for whatever reason. Due to the limitations of the system process being able to interact with the user space and display a notification, this had to be setup as a new service (`systemd-desktop-notifier@.service`) and accompanying timer. This new service is running within the user space, allowing desktop notifications to work properly. This optional but highly recommended. Without this, how will you know if your backups are working or not without manually verifying?

**Type**: bool

**Default**: false

**Required**: false

## Usage

### Install Restic and Start the Systemd Timer

```yaml
# playbook/group_vars/all.yml
restic_key_id: 5c657874
ssh_username: admin
restic_repo_path: /home/{{ ssh_username }}/backups/project_name
ssh_server_fqdn: server.host.xlocal
systemd_instance_name: whole-system-backup
enable_desktop_notifications: true # optional, but highly recommended.

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

### Restic Repo Password

The password for your repo needs to be saved to `{{ restic_service_account_home }}/{{ systemd_instance_name }}/{{ restic_key_id }}`. This file was created automatically with the correct permissions and just needs to be modified to include the repo password that matches the specified key id.

### Systemd Timers

You can check if the systemd timer is active by running `systemctl list-timers`.

## Credits

This was inspired by the work of [@tdemin](<https://github.com/tdemin>) who created a rather [thorough blog post](<https://tdem.in/post/restic-with-systemd/>) detailing the steps to create the systemd service and timer for restic. I used the steps he shared, converted it to an ansible module and added a few modifications of my own. Thank you Timur!

Additionally, credit goes to [@papanito](<https://github.com/papanito>) whose blog post (<https://wyssmann.com/blog/2021/07/notifications-for-failing-systemd-services/>) led me to a script he created, which I used and modified slightly to help me create my own convoluded desktop notification process.

I'd like to also thank the folks over at [SmallStep](<https://smallstep.com>) for publishing a neat [systemd service file](<https://github.com/smallstep/certificates/blob/master/systemd/step-ca.service>), containing all the config required to properly harden a service.

## Contributing

Have an idea or feature you'd like to implement? Submit a PR or file an issue! :slightly_smiling_face:

## License

[MIT](<https://github.com/charltonstanley/ansible-role-restic/blob/master/LICENSE>)
