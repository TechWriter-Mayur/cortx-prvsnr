{% set role = pillar['sspl']['role'] %}
# Copy conf file to /etc/sspl.conf
Copy sample file:
  file.copy:
    - name: /etc/sspl.conf
    - source: /opt/seagate/sspl/conf/sspl.conf.{{ pillar['sspl']['product'] }}
    - mode: 644

{% if 'virtual' in salt['grains.get']('productname').lower() %}
{% set role = 'vm' %}

# Execute only on Virtual Machine
Update sspl-ll conf file:
  file.replace:
    - name: /etc/sspl.conf
    - pattern: setup=.*$
    - repl: setup=vm
    - append_if_not_found: True

#Update sspl config file with pillar data:
#  module.run:
#    - eosconfig.update
#      - name: /etc/sspl.conf
#      - ref_pillar: sspl
#      - type: YAML
#      - backup: True

{% else %}

# Add zabbix user in sudoers file:
#   file.line:
#     - name: /etc/sudoers
#     - content: 'zabbix ALL=(ALL) NOPASSWD: ALL'
#     - mode: ensure
#     - after: '.*%wheel\s+ALL=\(ALL\)\s+NOPASSWD: ALL.*'
#     - backup: True

Create sudoers file for zabbix user:
  file.managed:
    - name: /etc/sudoers.d/zabbix
    - makedirs: True
    - replace: True
    - mode: 644
    - contents:
      - 'zabbix ALL=(ALL) NOPASSWD: ALL'
    
Ensure directory dcs_collector.conf.d exists:
  file.directory:
    - name: /etc/dcs_collector.conf.d
    - user: root
    - group: root
    - dir_mode: 755
    - file_mode: 644
    - recurse:
      - user
      - group
      - mode

Ensure file dcs_collector.conf exists:
  file.managed:
    - name: /etc/dcs_collector.conf
    - contents: |
        # Placeholder configuration. New configuration will be generated by Puppet.
        [general]
        config_dir=/etc/dcs_collector.conf.d/

        [hpi]

        [hpi_monitor]
    - require:
      - file: Ensure directory dcs_collector.conf.d exists

Start service dcs-collector:
  cmd.run:
    - name: /etc/rc.d/init.d/dcs-collector start
    - onlyif: test -f /etc/rc.d/init.d/dcs-collector
    - require:
      - file: Ensure file dcs_collector.conf exists

# END: Prepare for SSPL configuration

{% endif %}

Execute sspl_init script:
  cmd.run:
    - name: /opt/seagate/sspl/sspl_init config -f -r {{ role }}
    - onlyif: test -f /opt/seagate/sspl/sspl_init
