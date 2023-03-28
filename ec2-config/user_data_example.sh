Content-Type: multipart/mixed; boundary="==BOUNDARY==" 
MIME-Version: 1.0 
--==BOUNDARY==
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="cloud-config.txt"

#cloud-config
cloud_final_modules:
- [scripts-user, always]
--==BOUNDARY==
MIME-Version: 1.0 
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash -ex
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
sleep 5
echo BEGIN
date '+%Y-%m-%d %H:%M:%S'
yum install -y gcc libpng-devel libjpeg-devel
yum update -y && yum upgrade
cd /home/ec2-user
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
mkdir /home/ec2-user/.aws
yum config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
yum install terraform -y
yum install git -y
yum install python3 -y
yum groupinstall "Development Tools" -y
amazon-linux-extras install -y docker
service docker start
usermod -a -G docker ec2-user
systemctl enable docker
systemctl start docker

chown -R ec2-user:ec2-user /home/ec2-user/

mkdir -p /usr/lib/ssl
mkdir -p /etc/ssl/certs
mkdir -p /etc/pki/ca-trust/extracted/pem

ln -s /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem  /etc/ssl/certs/ca-certificates.crt
ln -s /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem /usr/lib/ssl/cert.pem 

# Optional: install miniconda, node, kubectl, helm and more
sudo -i -u ec2-user bash << EOF
mkdir ~/bin ~/tmp
cd ~/tmp
echo PATH="/home/ec2-user/bin:/home/ec2-user/python/bin:$PATH" >> /home/ec2-user/.bashrc
wget https://get.helm.sh/helm-v3.4.1-linux-amd64.tar.gz
tar -zxvf helm-v3.4.1-linux-amd64.tar.gz
mv linux-amd64/helm ~/bin
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl ~/bin
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
bash ~/.nvm/nvm.sh
source ~/.bashrc
nvm install node
npm config set registry http://registry.npmjs.org/
npm install -g awsudo
npm config set cafile /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
wget https://github.com/mozilla/sops/releases/download/v3.6.1/sops-v3.6.1.linux
chmod +x sops-v3.6.1.linux
mv sops-v3.6.1.linux ~/bin/sops
wget https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
chmod +x jq-linux64
mv jq-linux64 ~/bin/jq

cd /home/ec2-user
curl -O https://ssb.stsci.edu/releases/caldp/20201012/latest-linux.yml
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /home/ec2-user/miniconda.sh
bash /home/ec2-user/miniconda.sh -b -p /home/ec2-user/miniconda
rm -rf ~/tmp
cd /home/ec2-user
find /home/ec2-user/miniconda -name '*.pem' | grep -E 'ssl/cert.pem|ssl/cacert.pem' >/tmp/certs
for cert in `cat /tmp/certs`;
do
    echo "Replacing $cert"
    rm -v -f $cert
    ln -v -s /etc/ssl/certs/ca-certificates.crt $cert
done
EOF

chown -R ec2-user:ec2-user /home/ec2-user/

# Optional: Clone the repos
cd /home/ec2-user
# change to your name
mkdir rkein
cd rkein
# change to your github info
git clone https://github.com/spacetelescope/pyxis-aws
cd pyxis-aws
git config --local user.name "alphasentaurii"
## uncomment and change to your email
#git config --local user.email myname@stsci.edu
git remote add upstream https://github.com/spacetelescope/pyxis-aws --fetch --track main
git remote set-url upstream DISABLED --push

cd /home/ec2-user
chown -R ec2-user:ec2-user rkein/

echo "export CURL_CA_BUNDLE=/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem" >> /home/ec2-user/.bashrc
echo "export REQUESTS_CA_BUNDLE=/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem" >> /home/ec2-user/.bashrc


cat << EOF > /home/ec2-user/post_launch.sh
#!/bin/bash
eval "\$(/home/ec2-user/miniconda/bin/conda shell.bash hook)"
conda init
source ~/.bashrc
# conda config --add channels http://ssb.stsci.edu/stenv
# conda env create -n stenv --file latest-linux.yml
conda init bash
EOF

export AWS_DEFAULT_REGION=us-east-1

chown -R ec2-user:ec2-user /home/ec2-user/post_launch.sh
chown -R ec2-user:ec2-user /home/ec2-user/

echo END
--==BOUNDARY==--
