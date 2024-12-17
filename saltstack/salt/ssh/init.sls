openssh-server:
  pkg:
    - installed
    - name: {{ salt['pillar.get']('pkgs:openssh-server') }}

/etc/ssh/sshrc:
  file.managed:
    - source: salt://ssh/files/sshrc
    - user: root
    - group: root
    - mode: '0644'
    - follow_symlinks: True
    - require:
      - pkg: openssh-server

{% if not salt['grains.get']('virtual_subtype') or grains['virtual_subtype'] != 'Docker' %}
ssh:
  service:
    - name: {{ salt['pillar.get']('svcs:ssh') }}
    - running
    - enable: True
    - watch:
      - pkg: openssh-server
    - require:
      - pkg: openssh-server
      - file: /etc/ssh/sshrc
{% endif %}
