function __sops_key_file
    if test -f /etc/sops/age/keys.txt
        echo /etc/sops/age/keys.txt
    else
        echo $HOME/.config/sops/age/keys.txt
    end
end
