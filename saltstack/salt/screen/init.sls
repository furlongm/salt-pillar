screen:
  pkg.installed

/etc/screenrc:
  file.managed:
    - source: salt://screen/files/screenrc
    - user: root
    - group: root
    - mode: '0644'
    - follow_symlinks: True
