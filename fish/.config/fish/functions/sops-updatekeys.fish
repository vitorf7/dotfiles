function sops-updatekeys --description "Re-encrypt a sops file to match .sops.yaml recipients"
    if test (count $argv) -eq 0
        echo "Usage: sops-updatekeys <file>"
        return 1
    end
    SOPS_AGE_KEY_FILE=(__sops_key_file) sops updatekeys $argv[1]
end
