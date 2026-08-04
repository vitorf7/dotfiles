function sops-edit --description "Edit a sops-encrypted file"
    if test (count $argv) -eq 0
        echo "Usage: sops-edit <file>"
        return 1
    end
    EDITOR=nvim SOPS_AGE_KEY_FILE=(__sops_key_file) sops $argv[1]
end
