fail2ban:
  pkg:
    - installed
{% if not salt['grains.get']('virtual_subtype') or grains['virtual_subtype'] != 'Docker' %}
  service:
    - running
    - enable: True
    - watch:
      - file: /etc/fail2ban/fail2ban.local
      - file: /etc/fail2ban/jail.local
{% endif %}

/etc/fail2ban/jail.local:
  file.managed:
    - source: salt://fail2ban/files/jail.local.j2
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
    - follow_symlinks: True
    - require:
      - pkg: fail2ban

/etc/fail2ban/fail2ban.local:
  file.managed:
    - source: salt://fail2ban/files/fail2ban.local
    - user: root
    - group: root
    - mode: '0644'
    - follow_symlinks: True
    - require:
      - pkg: fail2ban
