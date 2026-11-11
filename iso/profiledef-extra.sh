
# ---------------------------------------------------------------------------
# DreamyOS additions (appended to archiso's releng profiledef.sh by
# scripts/build-iso.sh). Later lines override earlier ones.
# ---------------------------------------------------------------------------
iso_name="dreamyos"
iso_label="DREAMYOS_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="DreamyOS <https://github.com/tristntech/DreamyOS>"
iso_application="DreamyOS Live Medium"

file_permissions+=(
  ["/etc/gshadow"]="0:0:400"
  ["/etc/sudoers.d/10-dreamy-live"]="0:0:440"
  ["/usr/local/bin/dreamy-session"]="0:0:755"
  ["/usr/local/bin/dreamy-keybinds"]="0:0:755"
  ["/usr/local/bin/dreamy-power"]="0:0:755"
)
