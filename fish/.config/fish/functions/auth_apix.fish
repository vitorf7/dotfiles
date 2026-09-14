# mint a new uw iam token and add it to apix config, effectively 'logging in' to use apix
# against whichever domain is currently active in ~/.apix.yaml
function auth_apix
    set apix_config_path ~/.apix.yaml
    set -l domain (yq -r '.active' "$apix_config_path")

    if test -z "$domain"; or test "$domain" = "null"
        echo "No active apix domain set - see `apix list` / `apix switch`"
        return 1
    end

    set -l token (uw iam login --print --format gql --quiet | jq -r '.Authorization')
    or return

    env DOMAIN="$domain" TOKEN="$token" yq -i \
        '.domains[strenv(DOMAIN)].headers.Authorization = strenv(TOKEN)' \
        "$apix_config_path"

    echo "Token set for apix domain '$domain'"
end
