SSH_KEY=$(cat ~/.ssh/id_rsa.pub)
ssh root@192.168.51.225 'echo "'"$SSH_KEY"'" >> ~/.ssh/authorized_keys'
ssh root@192.168.51.225 'echo "'"$SSH_KEY"'" >> ~/.ssh/ciaran.pub'