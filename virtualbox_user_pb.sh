# Vérifier les membres du groupe "vboxsf" ou "vboxusers" dans la VM Ubuntu
getent group vboxsf

# Ajouter l'utilisateur actuel $USER au group VirtualBox "vboxsf" ou "vboxuers"
sudo usermod -aG vboxsf $USER
