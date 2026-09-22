function sops-edit --description "Edit a sops-encrypted file"
    if test (count $argv) -eq 0
        echo "Usage: sops-edit <file>"
        return 1
    end

    # sops-nix secrets declared with `format = "binary"` (e.g.
    # sops/nixos/wiresteward-config.json) store the whole payload as a single
    # string under a top-level "data" key. sops infers format from the file
    # extension, so for a .json binary file it parses the envelope as an
    # ordinary document and hands back the payload escaped inside
    # {"data": "..."} — unusable for editing and easy to corrupt on save.
    # A binary envelope is exactly two top-level keys: "data" and "sops".
    set -l fmt
    if jq -e 'type == "object" and has("data") and has("sops") and (keys | length) == 2' $argv[1] >/dev/null 2>&1
        set fmt --input-type binary --output-type binary
    end

    EDITOR=nvim SOPS_AGE_KEY_FILE=(__sops_key_file) sops $fmt $argv[1]
end
