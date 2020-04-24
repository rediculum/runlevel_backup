case "$SSH_ORIGINAL_COMMAND" in
  "test -d /"* |\
  "rdiff-backup --server" |\
  "id" \
  )
    logger -p auth.info -t backup_sshcmd "$LOGNAME executed: $SSH_ORIGINAL_COMMAND"
    $SSH_ORIGINAL_COMMAND # Execute
  ;;
  *)
    logger -p auth.warn -t backup_sshcmd "$LOGNAME denied: $SSH_ORIGINAL_COMMAND"
    echo "Command denied: \"$SSH_ORIGINAL_COMMAND\""
    exit 2
  ;;
esac

