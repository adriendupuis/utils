ssh_private_key=~/.ssh/id_rsa;
ssh_config_path=/etc/ssh/ssh_config;

echo 'SSH Forwarding Enablement Helper';
eval `ssh-agent`; # Run SSH Agent (Shouldn't be already/always running?)
ssh-add -K $ssh_private_key; # Add private key to SSH Agent including its passphrase
echo "ForwardAgent should be enable in $ssh_config_path:\n";
grep ForwardAgent -B1 $ssh_config_path;
#Host *
#  ForwardAgent yes
