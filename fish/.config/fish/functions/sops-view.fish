function sops-view --description "Decrypt a sops-encrypted file to stdout"
    if test (count $argv) -eq 0
        echo "Usage: sops-view <file>"
        return 1
    end

    # See sops-edit.fish for why binary-format files need explicit type flags.
    set -l fmt
    if jq -e 'type == "object" and has("data") and has("sops") and (keys | length) == 2' $argv[1] >/dev/null 2>&1
        set fmt --input-type binary --output-type binary
    end

    SOPS_AGE_KEY_FILE=(__sops_key_file) sops --decrypt $fmt $argv[1]
end
