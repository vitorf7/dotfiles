function sops-view --description "Decrypt a sops-encrypted file to stdout"
    if test (count $argv) -eq 0
        echo "Usage: sops-view <file>"
        return 1
    end
    SOPS_AGE_KEY_FILE=(__sops_key_file) sops --decrypt $argv[1]
end
