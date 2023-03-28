# EC2 Setup

1. Edit `user_data.sh` to suit your needs (change the home folder name from 'rkein' to your name, comment out anything you don't want, change github repo details, etc)

When you go to create your EC2 instance, copy paste the contents of `user_data.sh` into the last field in the "Advanced Settings" section

This script runs once, at instance creation time. If you already launched an EC2, you can also stop the instance, edit the user data, the restart, and it should run the script then.

CONDA STUFF

If you used the user_data.sh and want to setup a conda env, then the first time you login to the instance you will want to run the post_launch script as well:

```bash
$ sh post_launch.sh
```

# EC2 Login using SSO

An alternative to using SSH (if you have awscli installed on your machine)

```bash
aws configure sso
```

or if already configured:

```bash
aws sso login
```

Follow the prompts

```bash
# this is your instance id
instance="i-123456789"
aws ssm start-session --target $instance
#### Starting session with SessionId

    #    __|  __|_  )
    #    _|  (     /   Amazon Linux 2 AMI
    #   ___|\___|___|


sh-4.2$ sudo -i -u ec2-user
ec2-user@ip-123-45-67-890$
```

If you get an error, you may need to create an IAM role with the appropriate permissions and assign it to your instance profile.

1. In AWS console, go to your instance summary. 
2. From the `Instance state` dropdown menu, under "Security", click "Modify IAM Role"
3. Select the IAM role you created.
